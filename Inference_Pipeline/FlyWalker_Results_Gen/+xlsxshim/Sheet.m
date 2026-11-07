classdef Sheet < handle
    % One worksheet: Name, invoke(sheet,'Activate'), get(sheet,'Range',addr),
    % sheet.Range(addr).Value / .MergeCells (font colours are not reproduced).
    properties
        Name
        Cells = {}      % row x col cell array; [] = empty cell
        Merges = {}     % merged-range addresses, e.g. 'N10:Q10'
    end
    properties (Access = private)
        Book
    end
    methods
        function obj = Sheet(book, name)
            obj.Book = book;
            obj.Name = name;
        end
        function invoke(obj, name, varargin)
            assert(strcmpi(name, 'Activate'), 'xlsxshim: unsupported Sheet call %s', name);
            obj.Book.ActiveSheet = obj;
        end
        function r = get(obj, name, addr)
            assert(strcmpi(name, 'Range'), 'xlsxshim: unsupported Sheet property %s', name);
            r = xlsxshim.Range(obj, addr);
        end
        function obj = subsasgn(obj, S, val)
            % sheet.Range(addr).<Value|MergeCells|Font.ColorIndex> = val
            if numel(S) >= 3 && strcmp(S(1).type, '.') && strcmp(S(1).subs, 'Range') ...
                    && strcmp(S(2).type, '()')
                r = xlsxshim.Range(obj, S(2).subs{1});
                switch S(3).subs
                    case 'Value'
                        r.setValue(val);
                    case 'MergeCells'
                        if val, obj.Merges{end + 1} = r.Address; end
                    otherwise
                        % formatting only (Font colours): not reproduced
                end
            else
                obj = builtin('subsasgn', obj, S, val);
            end
        end
        function writeBlock(obj, r0, c0, data)
            [m, n] = size(data);
            if m == 0 || n == 0, return; end
            if size(obj.Cells, 1) < r0 + m - 1 || size(obj.Cells, 2) < c0 + n - 1
                obj.Cells{max(end, r0 + m - 1), max(size(obj.Cells, 2), c0 + n - 1)} = [];
            end
            obj.Cells(r0:r0 + m - 1, c0:c0 + n - 1) = data;
        end
    end
end

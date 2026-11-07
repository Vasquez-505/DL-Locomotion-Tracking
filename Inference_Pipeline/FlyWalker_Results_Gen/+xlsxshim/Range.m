classdef Range < handle
    % A cell range ('A1' or 'A1:B2'); set(range,'Value',v) follows Excel COM rules:
    % a scalar fills the whole range, larger data is truncated to the range.
    properties (SetAccess = private)
        Sheet
        Address
        R1
        C1
        R2
        C2
    end
    methods
        function obj = Range(sheet, addr)
            obj.Sheet = sheet;
            obj.Address = upper(strrep(char(addr), '$', ''));
            parts = strsplit(obj.Address, ':');
            [obj.R1, obj.C1] = xlsxshim.Range.parseCell(parts{1});
            [obj.R2, obj.C2] = xlsxshim.Range.parseCell(parts{end});
        end
        function set(obj, name, val)
            assert(strcmpi(name, 'Value'), 'xlsxshim: unsupported Range property %s', name);
            obj.setValue(val);
        end
        function setValue(obj, val)
            if ischar(val) || isstring(val)
                data = cellstr(val);
            elseif iscell(val)
                data = val;
            else
                data = num2cell(val);
            end
            nr = obj.R2 - obj.R1 + 1;
            nc = obj.C2 - obj.C1 + 1;
            if isscalar(data)
                data = repmat(data, nr, nc);
            else
                data = data(1:min(end, nr), 1:min(end, nc));
            end
            obj.Sheet.writeBlock(obj.R1, obj.C1, data);
        end
    end
    methods (Static)
        function [r, c] = parseCell(ref)
            tok = regexp(ref, '^([A-Z]+)(\d+)$', 'tokens', 'once');
            assert(~isempty(tok), 'xlsxshim: unsupported cell reference %s', ref);
            c = 0;
            for ch = tok{1}
                c = c * 26 + (ch - 'A' + 1);
            end
            r = str2double(tok{2});
        end
    end
end

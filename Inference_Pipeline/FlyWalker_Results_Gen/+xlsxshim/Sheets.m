classdef Sheets < handle
    % Workbook.Sheets: Count, get(sheets,'Item',k), invoke(sheets,'Add',[],after,n).
    properties (SetAccess = private)
        Items = {}
    end
    properties (Dependent)
        Count
    end
    properties (Access = private)
        Book
    end
    methods
        function obj = Sheets(book)
            obj.Book = book;
        end
        function n = get.Count(obj)
            n = numel(obj.Items);
        end
        function s = append(obj)
            s = xlsxshim.Sheet(obj.Book, sprintf('Sheet%d', numel(obj.Items) + 1));
            obj.Items{end + 1} = s;
        end
        function s = get(obj, name, k)
            assert(strcmpi(name, 'Item'), 'xlsxshim: unsupported Sheets property %s', name);
            s = obj.Items{k};
        end
        function invoke(obj, name, ~, ~, n)
            % Add n sheets after the last one (the only form FlyWalker uses)
            assert(strcmpi(name, 'Add'), 'xlsxshim: unsupported Sheets call %s', name);
            for i = 1:n
                obj.append();
            end
        end
    end
end

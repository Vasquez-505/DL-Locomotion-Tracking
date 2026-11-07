classdef Workbooks < handle
    % exl.Workbooks: only invoke(exlWkbk, 'Add') is used.
    properties (Access = private)
        App
    end
    methods
        function obj = Workbooks(app)
            obj.App = app;
        end
        function wb = invoke(obj, name, varargin)
            assert(strcmpi(name, 'Add'), 'xlsxshim: unsupported Workbooks call %s', name);
            wb = xlsxshim.Workbook();
            obj.App.ActiveWorkBook = wb;
        end
    end
end

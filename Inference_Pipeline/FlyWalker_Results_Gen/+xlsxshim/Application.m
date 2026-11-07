classdef Application < handle
    % Stand-in for actxserver('excel.application') on systems without Excel COM
    % (macOS/Linux). Implements only the calls EvaluateFlyTable_activex_hexa.m
    % makes; values and formulas are recorded and Workbook.SaveAs writes .xlsx.
    properties
        Workbooks
        ActiveWorkBook
    end
    properties (Dependent)
        Activesheet
    end
    methods
        function obj = Application()
            obj.Workbooks = xlsxshim.Workbooks(obj);
        end
        function s = get.Activesheet(obj)
            s = obj.ActiveWorkBook.ActiveSheet;
        end
        function set.Activesheet(~, ~)
            % `exl.Activesheet.Name = ...` writes the same handle back: nothing to do
        end
        function invoke(~, varargin)
            % 'Quit': nothing to release
        end
    end
end

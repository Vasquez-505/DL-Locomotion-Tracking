classdef Workbook < handle
    % Workbook: Sheets, SaveAs(path, fmt), Close(...). SaveAs writes a minimal,
    % standards-compliant .xlsx (inline strings, formulas recalculated on open).
    properties
        Sheets
        ActiveSheet
    end
    methods
        function obj = Workbook()
            obj.Sheets = xlsxshim.Sheets(obj);
            obj.ActiveSheet = obj.Sheets.append();   % new workbooks open with one sheet
        end
        function Close(~, varargin)
        end
        function SaveAs(obj, path, varargin)
            path = strrep(char(path), '\', filesep);
            tmp = tempname;
            cleanup = onCleanup(@() rmdir(tmp, 's'));
            mkdir(fullfile(tmp, '_rels'));
            mkdir(fullfile(tmp, 'xl', '_rels'));
            mkdir(fullfile(tmp, 'xl', 'worksheets'));
            n = obj.Sheets.Count;
            ns = 'http://schemas.openxmlformats.org';
            hdr = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';

            ct = [hdr '<Types xmlns="' ns '/package/2006/content-types">' ...
                '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' ...
                '<Default Extension="xml" ContentType="application/xml"/>' ...
                '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'];
            sheetsXml = '';
            relsXml = '';
            for k = 1:n
                ct = [ct sprintf(['<Override PartName="/xl/worksheets/sheet%d.xml" ' ...
                    'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'], k)]; %#ok<AGROW>
                sh = obj.Sheets.get('Item', k);
                sheetsXml = [sheetsXml sprintf('<sheet name="%s" sheetId="%d" r:id="rId%d"/>', ...
                    xlsxshim.Workbook.esc(sh.Name), k, k)]; %#ok<AGROW>
                relsXml = [relsXml sprintf(['<Relationship Id="rId%d" Type="' ns ...
                    '/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet%d.xml"/>'], k, k)]; %#ok<AGROW>
                xlsxshim.Workbook.writeText(fullfile(tmp, 'xl', 'worksheets', sprintf('sheet%d.xml', k)), ...
                    xlsxshim.Workbook.sheetXml(sh, hdr, ns));
            end
            xlsxshim.Workbook.writeText(fullfile(tmp, '[Content_Types].xml'), [ct '</Types>']);
            xlsxshim.Workbook.writeText(fullfile(tmp, '_rels', '.rels'), [hdr ...
                '<Relationships xmlns="' ns '/package/2006/relationships">' ...
                '<Relationship Id="rId1" Type="' ns '/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' ...
                '</Relationships>']);
            xlsxshim.Workbook.writeText(fullfile(tmp, 'xl', 'workbook.xml'), [hdr ...
                '<workbook xmlns="' ns '/spreadsheetml/2006/main" xmlns:r="' ns '/officeDocument/2006/relationships">' ...
                '<sheets>' sheetsXml '</sheets><calcPr calcId="0" fullCalcOnLoad="1"/></workbook>']);
            xlsxshim.Workbook.writeText(fullfile(tmp, 'xl', '_rels', 'workbook.xml.rels'), [hdr ...
                '<Relationships xmlns="' ns '/package/2006/relationships">' relsXml '</Relationships>']);

            zipFile = [tempname '.zip'];
            zip(zipFile, {'[Content_Types].xml', '_rels', 'xl'}, tmp);
            movefile(zipFile, path, 'f');
        end
    end
    methods (Static, Access = private)
        function xml = sheetXml(sh, hdr, ns)
            [m, n] = size(sh.Cells);
            rows = cell(1, m);
            for r = 1:m
                cells = cell(1, n);
                for c = 1:n
                    cells{c} = xlsxshim.Workbook.cellXml(sh.Cells{r, c}, ...
                        [xlsxshim.Workbook.colName(c) num2str(r)]);
                end
                body = [cells{:}];
                if ~isempty(body)
                    rows{r} = sprintf('<row r="%d">%s</row>', r, body);
                end
            end
            merges = '';
            if ~isempty(sh.Merges)
                merges = sprintf('<mergeCells count="%d">%s</mergeCells>', numel(sh.Merges), ...
                    sprintf('<mergeCell ref="%s"/>', sh.Merges{:}));
            end
            xml = [hdr '<worksheet xmlns="' ns '/spreadsheetml/2006/main"><sheetData>' ...
                [rows{:}] '</sheetData>' merges '</worksheet>'];
        end
        function x = cellXml(v, ref)
            x = '';
            if isempty(v)
                return
            end
            if isstring(v), v = char(v); end
            if ischar(v)
                num = str2double(v);
                if ~isempty(v) && v(1) == '='                          % formula
                    x = sprintf('<c r="%s"><f>%s</f></c>', ref, xlsxshim.Workbook.esc(v(2:end)));
                elseif ~isnan(num) && ~isempty(regexp(strtrim(v), ...
                        '^[-+]?(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?$', 'once'))
                    % Excel COM parses numeric text into numbers (as when typing it)
                    x = sprintf('<c r="%s"><v>%.17g</v></c>', ref, num);
                else
                    x = sprintf('<c r="%s" t="inlineStr"><is><t xml:space="preserve">%s</t></is></c>', ...
                        ref, xlsxshim.Workbook.esc(v));
                end
            elseif islogical(v)
                x = sprintf('<c r="%s" t="b"><v>%d</v></c>', ref, v(1));
            elseif isnumeric(v) && isfinite(v(1))
                x = sprintf('<c r="%s"><v>%.17g</v></c>', ref, double(v(1)));
            end                                                      % NaN/Inf: left empty
        end
        function s = colName(c)
            s = '';
            while c > 0
                rem_ = mod(c - 1, 26);
                s = [char('A' + rem_) s]; %#ok<AGROW>
                c = floor((c - 1) / 26);
            end
        end
        function s = esc(s)
            s = strrep(s, '&', '&amp;');
            s = strrep(s, '<', '&lt;');
            s = strrep(s, '>', '&gt;');
            s = strrep(s, '"', '&quot;');
        end
        function writeText(path, txt)
            fid = fopen(path, 'w', 'n', 'UTF-8');
            fwrite(fid, unicode2native(txt, 'UTF-8'));
            fclose(fid);
        end
    end
end

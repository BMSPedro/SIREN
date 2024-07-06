tableextension 50105 Vendor extends Vendor
{
    fields
    {
        field(50100; "SIREN Number"; text[100])
        {
            trigger OnValidate()
            var
                TempvatValidationLogDetails: Record "VAT Registration Log Details" temporary;
                regexCU: Codeunit Regex;
                checksiren: Codeunit CheckSIREN;
                vatRegistrationField: Enum "VAT Reg. Log Details Field";
                vatRegistrationStatus: enum "VAT Reg. Log Details Status";
                resultdic: Dictionary of [text, text];
                sirenRegexPatternLbl: Label '(\d{9}|\d{3}[-]\d{3}[-]\d{3})';
            begin
                if rec."SIREN Number" <> '' then begin
                    if not regexCU.isMatch(rec."SIREN Number", sirenRegexPatternLbl) then
                        error('The SIREN number does not have the correct format');

                    if not checkSIRENLuhnAlgo(rec."SIREN Number") then
                        error('The SIREN number is nor valid')
                end;

                checksiren.checkSIREN(rec."SIREN Number", resultdic);
                if resultdic.get('total_results') <> '' then begin
                    TempvatValidationLogDetails.Init();
                    TempvatValidationLogDetails."Log Entry No." := 1;
                    TempvatValidationLogDetails."Field Name" := vatRegistrationField::Name;
                    TempvatValidationLogDetails."Current Value" := rec.Name;
                    TempvatValidationLogDetails.Status := vatRegistrationStatus::"Not Valid";
                    TempvatValidationLogDetails."Account No." := rec."No.";
                    TempvatValidationLogDetails.Response := copystr(resultdic.Get('nom_complet'), 1, 150);
                    TempvatValidationLogDetails.Insert();

                    TempvatValidationLogDetails.Init();
                    TempvatValidationLogDetails."Log Entry No." := 2;
                    TempvatValidationLogDetails."Field Name" := vatRegistrationField::Address;
                    TempvatValidationLogDetails."Current Value" := rec.Address;
                    TempvatValidationLogDetails.Status := vatRegistrationStatus::"Not Valid";
                    TempvatValidationLogDetails."Account No." := rec."No.";
                    TempvatValidationLogDetails.Response := copystr(resultdic.Get('adresse'), 1, 150);
                    TempvatValidationLogDetails.Insert();

                    TempvatValidationLogDetails.Init();
                    TempvatValidationLogDetails."Log Entry No." := 3;
                    TempvatValidationLogDetails."Field Name" := vatRegistrationField::"Post Code";
                    TempvatValidationLogDetails."Current Value" := rec."Post Code";
                    TempvatValidationLogDetails.Status := vatRegistrationStatus::"Not Valid";
                    TempvatValidationLogDetails."Account No." := rec."No.";
                    TempvatValidationLogDetails.Response := copystr(resultdic.Get('code_postal'), 1, 150);
                    TempvatValidationLogDetails.Insert();

                    TempvatValidationLogDetails.Init();
                    TempvatValidationLogDetails."Log Entry No." := 4;
                    TempvatValidationLogDetails."Field Name" := vatRegistrationField::City;
                    TempvatValidationLogDetails."Current Value" := rec.City;
                    TempvatValidationLogDetails.Status := vatRegistrationStatus::"Not Valid";
                    TempvatValidationLogDetails."Account No." := rec."No.";
                    TempvatValidationLogDetails.Response := copystr(resultdic.Get('libelle_commune'), 1, 150);
                    TempvatValidationLogDetails.Insert();

                    TempvatValidationLogDetails.Reset();
                    TempvatValidationLogDetails.SetRange("Account No.", rec."No.");
                    Page.RunModal(Page::"VAT Registration Log Details", TempvatValidationLogDetails);
                end;
            end;

        }
    }
    local procedure checkSIRENLuhnAlgo(SIRENcode: text): Boolean
    var
        i: Integer;
        j: Integer;
        p: Integer;
        n: Integer;
        m: Integer;
        sum: Integer;
    begin
        for i := 1 to StrLen(SIRENcode) do begin
            Clear(j);
            Clear(n);
            Clear(m);
            Clear(n);
            if (i mod 2) = 0 then begin
                Evaluate(j, CopyStr(SIRENcode, i, 1));
                j := J * 2;
                if StrLen(format(j)) > 1 then begin
                    for p := 1 to StrLen(format(j)) do begin
                        Clear(n);
                        Evaluate(n, CopyStr(format(j), p, 1));
                        m := m + n;
                    end;
                    j := m;
                end;
            end else begin
                Evaluate(j, CopyStr(SIRENcode, i, 1));
                j := J * 1;
            end;
            sum := sum + j;
        end;
        if sum mod 10 = 0 then
            exit(true)
        else
            exit(false);
    end;

}
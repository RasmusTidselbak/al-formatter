page 70079673 "CSP Bank Card"
{
    procedure CreateBankInformation(var BankAccount: Record "Bank Account");
    var
        RegNoBank: Record "CSP RegNo/Bank";
        ResponseCode: Integer;
        UseDirectDescriptionTxt: TextConst
            DAN='Vælg hvordan banken skal modtage betalingsfiler. (Direkte kommunikation kræver at der er indgået end aftale med banken)',
            ENU='Choose how the bank should recieve files when exporting/sending payments (Direct Communication requires an agreement with bank)';
        UseDirectOptionTxt: TextConst
            DAN='Direkte kommunikation,Manuelt upload)',
            ENU='Direct Communication,Manual Upload';
    begin
        if something then
            repeat
            until some.Next = 0;
        if BankAccount."Bank Branch No." <> '' then begin
            if RegNoBank.Get(BankAccount."Bank Branch No.") then begin
                ResponseCode := SetupBankAndCentral(RegNoBank,BankAccount);
                case ResponseCode of
                    1:
                        Message(BankInfoCreatedTxt);
                    2:
                        Message(CentralNotFoundTxt);
                    3:
                        ; //test
                        
                end;
                BankAccount."CSP Bank Code" := RegNoBank."Bank Code";
            end else
                statement; // Give ErrorMsg. (Bank Branch No. unknown.)
        end else
            Error(MissingBankBranchNoErr);
    end;
    //TEST
    
    procedure "SetImport/ExportFormat"(var Account: Record 270);
    var
        xAccount: Record "Bank Account";
        Cr: Char;
        Lf: Char;
        Selection: Integer;
        CrLf: Text;
    begin
        //BankRec.GET(BankFilter);
        Cr := 13;
        Lf := 10;
        CrLf := Format(Cr)+ Format(Lf);
        xAccount := Account;
        if "Bank System Code" in ['DBISO20022','BCISO20022'] then begin
            if (Account."Payment Export Format" <> "Bank System Code") and
                (Account."Bank Statement Import Format" <> 'CSISO20022')
            then begin
                Account."Payment Export Format" := "Bank System Code";
                Account."Bank Statement Import Format" := 'CSISO20022';
            end else
                if Account."Payment Export Format" <> "Bank System Code" and
                    Account."Payment Export Format" <> "Bank System Code" or
                    Account."Payment Export Format" <> "Bank System Code" and
                    Account."Payment Export Format" <> "Bank System Code"
                then begin
                    Account."Payment Export Format" := "Bank System Code";
                end else if Account."Bank Statement Import Format" <> 'CSISO20022' then begin
                    Account."Bank Statement Import Format" := 'CSISO20022';
                end;
        end else begin
            if Account."Payment Export Format" <> "Bank System Code" then
                Account."Payment Export Format" := "Bank System Code";
        end;
    end;
}
page 70079673 "CSP Bank Card"
{
    
}

table 10000 test
{

    fields
    {
        field(1;MyField;Integer)
        {
        }
    }

    keys
    {
        key(PK;MyField)
        {
            Clustered = true;
        }
    }
    
    var
        myInt : Integer;

    trigger OnInsert();
    begin
    end;

    trigger OnModify();
    begin
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
    end;

}
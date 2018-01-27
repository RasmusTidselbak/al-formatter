page 70079673 "CSP Bank Card"
{
  PageType = Card;
  SourceTable = "CSP Bank";
  CaptionML=ENU='this';

  layout
  {
    area(content)
    {
      group(General)
      {
        CaptionML=DAN='Generelt',
                  ENU='General';
        field("Bank Code";"Bank Code")
        {
            trigger OnValidate();
            begin
              CurrPage."CS Bank Account Part".Page.SetBankFilter("Bank Code");              
            end;
        }
        field("Bank System Code";"Bank System Code")
        {
          trigger OnValidate();
          begin
            CurrPage.Update;            
          end;
        }
        field("Bank Name";"Bank Name")
        {
          
        }
       field(Direct;Direct)
        {
          CaptionML=DAN='Direkte',
                    ENU='Direct';
          Enabled=DirectEnabled;

          trigger OnValidate();
          begin
            CurrPage.UPDATE;
          end;
        }
        field(Subsystem;Subsystem)
        {
          Enabled=SubSysEnabled;
        }
        field("Bank Branch No.";"Bank Branch No.")
        {
          Enabled=BBNEnabled;
        }
        field("Cash. Vendor No.";"Cash. Vendor No.")
        {
          Enabled=CashVendorNoEnabled;
        }
      }
      group(Security)
      {
        CaptionML=DAN='Sikkerhed',
                  ENU='Security';
        field(UserName;UserName)
        {
          CaptionML=DAN='Brugernavn',
                    ENU='User Number';
        }
        field(SecurityCode;SecurityCode)
        {
        }
        field("Certificate Created";CertificateCreated)
        {
          CaptionML=DAN='Certifikat oprettet',
                    ENU='Certificate Created';
          Editable=false;
        }
      }
      part("CS Bank Account Part";"CSP Bank Account Part")
      {
        CaptionML=DAN='Kontooversigt',
                  ENU='Account overview';
        ShowFilter=true;
        SubPageLink="CSP Bank Code"=FIELD("Bank Code");
      }
      group(Advanced)
      {
        CaptionML=DAN='Avanceret',
                  ENU='Advanced';
        
        field("Use shared Certificate";"Use shared Certificate")
        {
          Editable=SharedCertEditable;
        }
        field("Use Filelog";"Use Filelog")
        {
        }
        field("File Log period";"File Log period")
        {
        }
        field(StatusLevel;BankSystem."Status Level")
        {
          CaptionML=DAN='Status niveau',
                    ENU='Status Level';
          Editable=false;
          Enabled=StatusEnabled;
          TableRelation="CSP Bank Systems"."Status Level" WHERE (Code=FIELD("Bank System Code"));
        }
      }
    }
  }

  actions
  {
    area(creation)
    {
      group(SetupGroup)
      {
        CaptionML=DAN='Opsætning',
                  ENU='Setup';
        Image=Setup;
        action("Create Certificates")
        {
          CaptionML=DAN='Opret certifikater',
                    ENU='Create Certificates';
          Image=Certificate;
          Promoted=true;
          PromotedCategory=Process;
          PromotedIsBig=true;
          Visible=true;

          trigger OnAction();
          var
            Result : Boolean;
            MessageText : Text;
            BankSystem : Record 70079671;
            UserPage : Page 70079705;
            CertHandling : Codeunit 70079675;
          begin
            CertHandling.CreateCertificate(Rec,'');
            CurrPage.UPDATE;
          end;
        }
        action("User Information")
        {
          CaptionML=DAN='Bruger oplysninger',
                    ENU='User Information';
          Image=Users;
          Promoted=true;
          PromotedCategory=Process;

          trigger OnAction();
          var
            UserPage : Page 70079705;
            UserInfo : Record 70079701;
            BankSystem : Record 70079671;
          begin
            BankSystem.GET("Bank System Code");
            IF Direct THEN BEGIN
              UserInfo.SETRANGE("System Code","Bank Code");
              IF "Use shared Certificate" THEN
                UserInfo.SETRANGE("User ID",'')
              ELSE
                UserInfo.SETFILTER("User ID",'<>%1','');
              UserPage.Initialize("Bank Code");
              UserPage.SETTABLEVIEW(UserInfo);
              IF UserPage.RUNMODAL = ACTION::OK THEN
                CurrPage.UPDATE;
            END ELSE
              ERROR(Text000);
          end;
        }
        action("Import Certificate")
        {
          CaptionML=DAN='Importer certifikat',
                    ENU='Import Certificate';
          Image=Import;
          //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
          //PromotedIsBig=true;

          trigger OnAction();
          begin
            UserInfo.ImportCertificateXml("Bank Code",'',UserName,SecurityCode);
          end;
        }
        action("Export Certificate")
        {
          CaptionML=DAN='Eksporter certifikat',
                    ENU='Export Certificate';
          Image=Export;

          trigger OnAction();
          var
            UserInfo : Record "CSP User Information";
          begin
            IF NOT UserInfo.GET("Bank Code",'') THEN
              ERROR(NoSharedCertificate);
            UserInfo.ExportCertificate;
          end;
        }
      }
      action("Xml Log")
      {
        CaptionML=DAN='Xml overf¢rselslog',
                  ENU='Xml transfer log';
        Image=Archive;

        trigger OnAction();
        var
          XmlArchive : Page "CSP File Archive";
          XmlArchiveRec : Record "CSP File Archive";
        begin
          XmlArchiveRec.SETRANGE("System Code","Bank Code");
          IF XmlArchiveRec.FIND('-') THEN;
          XmlArchive.SETTABLEVIEW(XmlArchiveRec);
          XmlArchive.RUN;
        end;
      }
      action("Add Account")
      {
        CaptionML=DAN='Tilf¢j eksisterende bankkonto',
                  ENU='Add existing Bank Account';
        Promoted=true;
        PromotedCategory=Process;

        trigger OnAction();
        var
          AccountRec : Record "Bank Account";
          xAccountRec : Record "Bank Account";
          AccountList : Page "Bank Account List";
        begin
          CLEAR(AccountRec);
          AccountList.SETRECORD(AccountRec);
          AccountList.LOOKUPMODE := TRUE;
          IF (AccountList.RUNMODAL = ACTION::LookupOK) THEN BEGIN
            AccountList.GETRECORD(AccountRec);
            xAccountRec := AccountRec;
            AccountRec."CSP Bank Code" := Rec."Bank Code";
            "SetImport/ExportFormat"(AccountRec);
            IF (xAccountRec."Payment Export Format" <> AccountRec."Payment Export Format") OR
             (xAccountRec."Bank Statement Import Format" <> AccountRec."Bank Statement Import Format") OR
             (xAccountRec."CSP Bank Code" <> AccountRec."CSP Bank Code")
            THEN
              AccountRec.MODIFY;
            CurrPage.UPDATE;
          END;
        end;
      }
    }
  }

  trigger OnAfterGetRecord();
  begin
    UserInfo.SETRANGE("System Code","Bank Code");
    IF "Use shared Certificate" THEN
      UserInfo.SETRANGE("User ID",'')
    ELSE
      UserInfo.SETRANGE("User ID",USERID);

    CertificateCreated := FALSE;

    IF UserInfo.FIND('-') THEN BEGIN
      REPEAT
        UserInfo.CALCFIELDS(Certificate);
        IF UserInfo.Certificate.HASVALUE THEN
          CertificateCreated := TRUE;
      UNTIL UserInfo.NEXT = 0;
    END;
    SetFieldVisibility;
    CurrPage."CS Bank Account Part".PAGE.SetBankFilter("Bank Code");
  end;

  // trigger OnInsertRecord(BelowxRec : Boolean) : Boolean;
  // begin
  //   // SetFieldVisibility;
  // end;

  // trigger OnModifyRecord() : Boolean;
  // begin
  //   // SetFieldVisibility;
  // end;


    procedure BaseUrl():Text;
    begin
        case true of
            IsDev:
                exit('https://devauth.continiaonline.com/api/v1/');
            IsDemo:
                exit('https://demoauth.continiaonline.com/api/v1/');
            else
                exit('https://auth.continiaonline.com/api/v1/');
        end;
    end;

  trigger OnNewRecord(BelowxRec : Boolean);
  begin
    UserInfo.SETRANGE("System Code","Bank Code");
    CertificateCreated := FALSE;
    IF UserInfo.FIND('-') THEN BEGIN
      REPEAT
        UserInfo.CALCFIELDS(Certificate);
        IF UserInfo.Certificate.HASVALUE THEN
          CertificateCreated := TRUE;
      UNTIL UserInfo.NEXT = 0;
    END;
    SetFieldVisibility;
  end;

  var
    Text000 : TextConst DAN='Denne funktion kan kun benyttes ved direkte kommunikation',ENU='This function can only be used with Direct Communication';
    CertificateCreated : Boolean;
    DirectEnabled : Boolean;
    UserInfo : Record "CSP User Information";
    StatusEnabled : Boolean;
    BBNEnabled : Boolean;
    SubSysEnabled : Boolean;
    CashVendorNoEnabled : Boolean;
    BankSystem : Record "CSP Bank Systems";
    Text001 : TextConst DAN='Dette banksystem underst¢tter ikke direkte kommunikation',ENU='This Bank System does not support Direct Communication';
    Text002 : TextConst DAN='Certifikat blev succesfuldt oprettet.',ENU='Certificate was succesfully created.';
    BCISO : Boolean;
    SharedCertEditable : Boolean;
    RunOnServerEditable : Boolean;
    NoSharedCertificate : TextConst DAN='Der kunne ikke findes et delt certifikat',ENU='A shared Certificate could not be found';
    AccountPart : Page "CSP Bank Account Part";
    Text007 : TextConst DAN='Kontoen er allerede tilknyttet en bank. Er du sikker på du vil ændre dette?',
    ENU='The Account is allready attached to a Bank, Are you shure you want to change this?';
    Text008 : TextConst DAN='Feltet "Format til eksport af betaling" på %1 stemmer ikke overens med systemet for banken! %2Vil du ændre formatet for kontoen?',
    ENU='The field "Payment Export Format" for %1 does not match the system of the Bank! %2 Do you wish to change the format for the Account?';
    Text003 : TextConst DAN='Feltet "Format til eksport af betaling" på %1 stemmer ikke overens med systemet for banken!',
    ENU='The field "Payment Export Format" for %1 does not match the system of the Bank! ';
    Text004 : TextConst DAN='Feltet "Format til import af bankkontoudtog" på %1 stemmer ikke overens med systemet for banken! %2Vil du ændre formatet for kontoen?',
    ENU='The field "Bank Statement Import Format" for %1 does not match the system of the Bank! %2Do you wish to change the format for the Account?';
    Text005 : TextConst DAN='Felterne "Format til eksport af betaling" og "Format til import af bankkontoudtog" på kontoen %1 stemmer ikke overens med systemet for banken! %2 Vil du ændre formatet for kontoen?',ENU='The fields "Payment Export Format" and "Bank Statement Import Format" for the account %1 do not match the system of the Bank! %2 Do you wish to change the format for the Account?';
    Text006 : TextConst DAN='Sæt export-format,Sæt import-format,Sæt begge formater',ENU='Set export-format,Set import-format,Set both formats';

  local procedure SetFieldVisibility();
  begin
    BCISO := FALSE;
    StatusEnabled := FALSE;
    BBNEnabled := FALSE;
    SubSysEnabled := FALSE;
    CashVendorNoEnabled := FALSE;
    SharedCertEditable := FALSE;


    IF BankSystem.GET("Bank System Code") THEN BEGIN
      DirectEnabled := BankSystem.DirectSupported;

      IF "Bank System Code" = 'DBISO20022' THEN BEGIN
        StatusEnabled := TRUE;
        IF Direct THEN
          SharedCertEditable := TRUE;
      END;

      IF "Bank System Code" = 'BCISO20022' THEN BEGIN
        SharedCertEditable := TRUE;
        IF Direct THEN BEGIN
          BBNEnabled := TRUE;
          BCISO := TRUE;
        END ELSE
          SubSysEnabled := TRUE;
      END;

      IF "Bank System Code" = 'HBISO20022' THEN BEGIN
        CashVendorNoEnabled := TRUE;
        SharedCertEditable := TRUE;
        RunOnServerEditable := FALSE;
      END ELSE
        CashVendorNoEnabled := FALSE;
    END;
  end;

  procedure "SetImport/ExportFormat"(var Account : Record 270);
  var
    Selection : Integer;
    xAccount : Record "Bank Account";
    Cr : Char;
    Lf : Char;
    CrLf : Text;
  begin
    //BankRec.GET(BankFilter);
    Cr := 13;
    Lf := 10;
    CrLf := FORMAT(Cr) + FORMAT(Lf);
    xAccount := Account;
    IF "Bank System Code" IN ['DBISO20022','BCISO20022'] THEN BEGIN
      IF (Account."Payment Export Format" <> "Bank System Code") AND
          (Account."Bank Statement Import Format" <> 'CSISO20022')
      THEN BEGIN
          Account."Payment Export Format" := "Bank System Code";
          Account."Bank Statement Import Format" := 'CSISO20022';
      END ELSE IF Account."Payment Export Format" <> "Bank System Code" THEN BEGIN
          Account."Payment Export Format" := "Bank System Code";
      END ELSE IF Account."Bank Statement Import Format" <> 'CSISO20022' THEN BEGIN
          Account."Bank Statement Import Format" := 'CSISO20022';
      END;
    END ELSE BEGIN
      IF Account."Payment Export Format" <> "Bank System Code" THEN
          Account."Payment Export Format" := "Bank System Code";
    END;
  end;
  
}

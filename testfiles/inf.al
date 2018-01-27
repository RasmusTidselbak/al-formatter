Codeunit 70079730 "CSP Create Bank Information"
{
	trigger OnRun();
	begin
	end;
	
	var
		MissingBankBranchNoErr : TextConst DAN='Registrering nummer skal være udfyldt.',
			ENU='Bank Branch No. must be present.';
		BankInfoCreatedTxt : TextConst DAN='Bank information succesfuldt oprettet',
			ENU='Bank Information succesfully created';
		CentralNotFoundTxt : TextConst DAN='Der blev ikke fundet en matchende bankcentral',
			ENU='A matching Bank Central could not be found';
		UseDirectOptionTxt : TextConst DAN='Direkte kommunikation,Manuelt upload)',
			ENU='Direct Communication,Manual Upload';
		UseDirectDescriptionTxt: TextConst DAN='Vælg hvordan banken skal modtage betalingsfiler. (Direkte kommunikation kræver at der er indgået end aftale med banken)',
			ENU='Choose how the bank should recieve files when exporting/sending payments (Direct Communication requires an agreement with bank)';

		
	procedure CreateBankInformation(var BankAccount : Record "Bank Account");
	var
UseDirectOptionTxt : TextConst DAN='Direkte kommunikation,Manuelt upload)',
	ENU='Direct Communication,Manual Upload';
UseDirectDescriptionTxt: TextConst DAN='Vælg hvordan banken skal modtage betalingsfiler. (Direkte kommunikation kræver at der er indgået end aftale med banken)',
	ENU='Choose how the bank should recieve files when exporting/sending payments (Direct Communication requires an agreement with bank)';

		RegNoBank : Record "CSP RegNo/Bank";
		ResponseCode : Integer;
	begin
		if BankAccount."Bank Branch No." <> '' then begin
			if RegNoBank.Get(BankAccount."Bank Branch No.") then begin
				ResponseCode := SetupBankAndCentral(RegNoBank, BankAccount);
				case ResponseCode of
					1: Message(BankInfoCreatedTxt);
					2: Message(CentralNotFoundTxt);
					3: ; //Msg Ok bank already created/set up.
					// Additional messsages to be added along with assistance to the user on how to solve possible issues.
                    // Add Bank Code to Account if Bank creation succesfull.
				end;
				BankAccount."CSP Bank Code" := RegNoBank."Bank Code";
			end else
				;// Give ErrorMsg. (Bank Branch No. unknown.)
		end else
			Error(MissingBankBranchNoErr);
	end;
	local procedure SetupBankAndCentral(RegNoBank : Record "CSP RegNo/Bank"; BankAccount : Record "Bank Account")ReturnValue: Integer;
	var
		Bank : Record "CSP Bank";
		Bank_Central : Record "CSP Bank/Central";
		Direct : Boolean;
        Selection : Integer;
		BankCentral : Code[20];
	begin
		if Bank_Central.Get(RegNoBank."Bank Name") then begin
            if (Bank_Central."Bank Central (Direct)" <> '') AND (Bank_Central."Bank Central (Direct)" <> 'NOT SUPPORTED') then
			Selection := STRMENU(UseDirectOptionTxt,2,UseDirectDescriptionTxt);// Qst Use Direct Communication if supported?
			IF Selection = 0 then 
				ERROR('');
            Direct := Selection = 1;
			if Direct then
				BankCentral := Bank_Central."Bank Central (Direct)"
			else
				BankCentral := Bank_Central."Bank Central (Manual)";
			if not ImportBankCentral(BankCentral) then
				; // TODO
			ReturnValue := 1;	
		end else begin
			// Create bank_Central Record without central (var Bank_Central)
			// CreateBankRecord(Bank_Central);
			CreateBankRecord(RegnoBank,BankCentral, Direct);
            ReturnValue := 2;
            exit; // 2 = Message(CentralNotFoundTxt);    
		end;
		if not Bank.Get(RegNoBank."Bank Code") then
            CreateBankRecord(RegNoBank,BankCentral,Direct)
		else begin
            ReturnValue := 3;
            exit;
		end;
	end;
		
		local procedure CreateBankRecord(RegnoBank:Record "CSP RegNo/Bank";BankCentral:Code[20];DirectCommunication : Boolean) BankCode:Code[20];
		var
			Bank : Record "CSP Bank";
		begin
			with Bank do begin
				init;
				"Bank Code" := RegnoBank."Bank Code";
				"Bank Name" := RegnoBank."Bank Name";
				"Bank System Code" := BankCentral; // Direct
				Direct := DirectCommunication;
				"Use shared Certificate" := true;
				Insert;
			end;
		end;
		
		local procedure ImportBankCentral(BankCentral:Code[20]):Boolean;
		var
			Client : HttpClient;
			Request : HttpRequestMessage;
			Response : HttpResponseMessage;
		begin
			//Import Setup for chosen bank central
			// TODO
			// in first edition all supported centrals are installed..
		end;
		
	}
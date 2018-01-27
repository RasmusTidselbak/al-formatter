Codeunit 70000003 "Continia Online API"
{
    trigger OnRun();
    begin
    end;
    
    
    var
        ClientCredentials: Record "Continia Client Credentials";
        Config: Codeunit "Continia Core Config";
        Core: Codeunit "Continia Core";
        Toolbox: Codeunit "Continia Core Toolbox";
        HttpRequstErr: TextConst ENU='Could not contact Continia Online';
        JsonObjectExpectedErr: TextConst ENU='Invalid response, expected JSON object.';
        
    procedure TestPro();
    var
        myInt: Integer;
    begin
        "Line Discount %" := "Line Discount Amount" / "Line Value" * 100;
        StartDate := CALCDATE('<+' + FORMAT(Days + i)+ 'D>',StartDate);
        StartDate := 0D;
        // Initialize
        SomeOption := Something::Very;
    end;
    
    
    procedure ActivateProduct(): Boolean;
    var
        Activation: Record Activation temporary;
        CompanyInformation: Record "Company Information";
        ContiniaCompanySetup: Record "Continia Company Setup";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        httpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        JSONObject: JsonObject;
        JSONValue: JsonValue;
        JSONToken: JsonToken;
        AgreementElement: XmlElement;
        CompanyElement: XmlElement;
        RootElement: XmlElement;
        Document: XmlDocument;
        Reactivate: Boolean;
        JSONText: Text;
        XmlTxt: Text;
    begin
        CompanyInformation.Get;
        Reactivate := false;
        Activations(Activation);
        Activation.SetRange("Company GUID",Config.CompanyGUID);
        if Activation.FindFirst then begin
            if Activation."Company Name" = CompanyName then
                Reactivate := true
            else begin
                ContiniaCompanySetup.Get;
                ContiniaCompanySetup."Company GUID" := CreateGuid;
                ContiniaCompanySetup.Modify;
            end;
            
            
        end;
        
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        HttpHeaders.Add('Accept','application/json;charset=utf-8');
        HttpHeaders.Add('Authorization','Bearer ' + GetAccessToken);
        HttpHeaders.Add('Timeout','3000');
        if HttpContent.GetHeaders(HttpContentHeaders) then begin
            if HttpContentHeaders.Remove('Content-Type') then
                ;
            HttpContentHeaders.Add('Content-Type','application/json');
        end;
        
        AgreementElement := XmlElement.Create('LicenseAgreement');
        if Reactivate then
            AgreementElement.SetAttribute('Update','1')
        else
            AgreementElement.SetAttribute('Update','0');
        CompanyElement := XmlElement.Create('Company');
        CompanyElement.SetAttribute('CompanyGUID',Toolbox.GUIDtoText(Config.CompanyGUID));
        CompanyElement.SetAttribute('CompanyName',CompanyName);
        // Company Name returned from Continia Online
        CompanyElement.SetAttribute('CompanyInfoName',CompanyInformation.Name);
        CompanyElement.SetAttribute('VATRegNo',CompanyInformation."VAT Registration No.");
        CompanyElement.SetAttribute('NavVersion',Config.ProductID + ' ' + Config.ProductVersion);
        // Product Name and Version
        CompanyElement.SetAttribute('NAVAppVersion','Dynamics 365');
        CompanyElement.SetAttribute('ProductCode',Config.ProductID);
        CompanyElement.SetAttribute('ProductVersion',Config.ProductVersion);
        CompanyElement.SetAttribute('NAVLicenseSN',Config.SubscriptionID);
        AgreementElement.Add(CompanyElement);
        AgreementElement.WriteTo(XmlTxt);
        HttpContent.WriteFrom(XmlTxt);
        if not HttpClient.Put(Config.AcceptUrl,HttpContent,ResponseMessage) then
            Error(HttpRequstErr);
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error(JsonObjectExpectedErr);
        VerifyStatusOK(JSONObject);
        ContiniaCompanySetup.Get;
        ContiniaCompanySetup."Registered Company Name" := CompanyName;
        ContiniaCompanySetup.Modify;
        exit(true);
    end;
    
    
    procedure DeactivateProduct(Reason: Text);
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        JSONObject: JsonObject;
        JSONValue: JsonValue;
        JSONArray: JsonArray;
        JSONToken: JsonToken;
        JSONText: Text;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        HttpHeaders.Add('Accept','application/json;charset=utf-8');
        HttpHeaders.Add('Authorization','Bearer ' + GetAccessToken);
        HttpHeaders.Add('Timeout','3000');
        if HttpContent.GetHeaders(HttpContentHeaders) then
            if HttpContentHeaders.Remove('Content-Type') then
                HttpContentHeaders.Add('Content-Type','application/json');
        JSONObject.Add('product_id',Config.ProductID);
        JSONObject.Add('reason',Reason);
        JSONObject.AsToken.WriteTo(JSONText);
        HttpContent.WriteFrom(JSONText);
        if not HttpClient.Post(Config.DeactivateUrl,HttpContent,ResponseMessage) then
            Error(HttpRequstErr);
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error(JsonObjectExpectedErr);
        VerifyStatusOK(JSONObject);
        Core.TokenRequestAsync;
        // Update the token and the license.
        
    end;
    
    
    procedure GetAccessToken(): Text;
    var
        ContiniaCompanySetup: Record "Continia Company Setup";
        ContiniaOnlineAccessToken: Record "Continia Online Access Token";
        License: Record "Continia License";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        Granule: JsonObject;
        JSONObject: JsonObject;
        JSONToken: JsonToken;
        Token: JsonToken;
        IStream: InStream;
        OStream: OutStream;
        Status: Code[20];
        ExpiresIn: Integer;
        i: Integer;
        AccessToken: Text;
        JSONText: Text;
        ExpectedGranulesArrayErr: TextConst ENU='Invalid response, expected granules array';
        GranuleDoesntExistErr: TextConst ENU='Invalid token, expected Granule Array';
    begin
        if not ClientCredentials.Get then begin
            ClientCredentials.Init;
            ClientCredentials.Insert;
        end;
        
        if(ClientCredentials."Client ID" = '') or(ClientCredentials."Client Password" = ' ') then
            InitializeCredentials();
        if ContiniaOnlineAccessToken.Get then begin
            ContiniaOnlineAccessToken.CalcFields("Access Token");
            if ContiniaOnlineAccessToken."Access Token".HasValue and((ContiniaOnlineAccessToken."Token Timestamp" > CreateDateTime(Today,Time)-(30 * 60 * 1000)) or(ContiniaOnlineAccessToken."Token Timestamp" > CreateDateTime(Today,Time)- ContiniaOnlineAccessToken."Expires In (ms)")) then begin
                // Allow the access token to live for 30 minutes
                ContiniaOnlineAccessToken."Access Token".CreateInStream(IStream);
                IStream.ReadText(AccessToken);
                exit(AccessToken);
            end;
            
            
        end;
        
        HttpClient.DefaultRequestHeaders.Add('Accept','application/json;charset=utf-8');
        HttpContent.WriteFrom(Config.GetClientCredentials());
        if not HttpClient.Post(Config.AccessTokenUrl(),HttpContent,ResponseMessage) then
            Error(HttpRequstErr);
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error(JsonObjectExpectedErr);
        AccessToken := GetJsonToken(JSONObject,'access_token').AsValue.AsText;
        if JSONObject.Get('expires_in',JSONToken) then
            ExpiresIn := JSONToken.AsValue.AsInteger * 1000
        else
            ExpiresIn := 30 * 60 * 1000;
        // 30 min
        if JSONObject.Get('granules',JSONToken) then begin
            if not JSONToken.IsArray then
                Error(ExpectedGranulesArrayErr);
            for i := 0 to JSONToken.AsArray.Count - 1 do begin
                JSONToken.AsArray.Get(i,Token);
                Granule := Token.AsObject;
                License.Init;
                License."Product ID" := GetJsonToken(Granule,'product_id').AsValue.AsCode;
                License.Granule := GetJsonToken(Granule,'granule').AsValue.AsCode;
                Status := GetJsonToken(Granule,'status').AsValue.AsCode;
                case Status of
                    'ENABLED':
                        License.Status := License.Status::Enabled;
                    'DISABLED':
                        License.Status := License.Status::Disabled;
                end;
                
                License."Expiration Date" := GetJsonToken(Granule,'expiration_date').AsValue.AsDate;
                License.Message := GetJsonToken(Granule,'message').AsValue.AsText;
                if not License.Insert then
                    License.Modify;
                    
            end;
            
            
        end;
        
        if not ContiniaOnlineAccessToken.Get then begin
            ContiniaOnlineAccessToken.Init;
            ContiniaOnlineAccessToken.Insert;
        end;
        
        ContiniaOnlineAccessToken."Access Token".CreateOutStream(OStream,TextEncoding::Windows);
        OStream.WriteText(AccessToken);
        ContiniaOnlineAccessToken."Token Timestamp" := CurrentDateTime;
        ContiniaOnlineAccessToken."Expires In (ms)" := ExpiresIn;
        ContiniaOnlineAccessToken.Modify;
        if not ContiniaCompanySetup.Get then begin
            ContiniaCompanySetup.Initialize;
            ContiniaCompanySetup.Insert;
        end;
        
        if ContiniaCompanySetup."Registered Company Name" <> CompanyName then
            ActivateProduct();
        exit(AccessToken);
    end;
    
    
    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    var
        TokenMissingErr: TextConst ENU='Could not find a token with key %1';
    begin
        if not JSONObject.Get(TokenKey,JSONToken) then
            Error(TokenMissingErr,TokenKey);
            
    end;
    
    
    procedure InitializeCredentials();
    var
        ContiniaCompanySetup: Record "Continia Company Setup";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        JSONObject: JsonObject;
        JSONValue: JsonValue;
        JSONToken: JsonToken;
        JSONText: Text;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        if HttpContent.GetHeaders(HttpContentHeaders) then
            if HttpContentHeaders.Remove('Content-Type') then
                HttpContentHeaders.Add('Content-Type','application/json');
        JSONObject.Add('subscription_id',Config.SubscriptionID);
        JSONObject.Add('secret',Secret);
        JSONObject.AsToken.WriteTo(JSONText);
        HttpContent.WriteFrom(JSONText);
        if not HttpClient.Post(Config.LoginDetailsUrl,HttpContent,ResponseMessage) then
            Error(HttpRequstErr);
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error(JsonObjectExpectedErr);
        VerifyStatusOK(JSONObject);
        ClientCredentials.FindFirst;
        ClientCredentials."Client ID" := GetJsonToken(JSONObject,'client_id').AsValue.AsText;
        ClientCredentials."Client Password" := GetJsonToken(JSONObject,'client_password').AsValue.AsText;
        ClientCredentials.Modify;
    end;
    
    
    procedure Activations(var Activation: Record Activation);
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        ActivationObject: JsonObject;
        JSONObject: JsonObject;
        ActivationToken: JsonToken;
        JSONToken: JsonToken;
        NewGuid: Guid;
        i: Integer;
        JSONText: Text;
        ExpectedActivationsArrayErr: TextConst ENU='Invalid response, expected activations array';
        HttpRequstErr: TextConst ENU='Could not contact service';
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        HttpHeaders.Add('Accept','application/json;charset=utf-8');
        HttpHeaders.Add('Authorization','Bearer ' + GetAccessToken);
        if not HttpClient.Get(Config.BaseUrl + 'LicenseAgreement/Activations',ResponseMessage) then
            Error(HttpRequstErr);
        ResponseMessage.Content.ReadAs(JSONText);
        if JSONObject.Get('activations',JSONToken) then begin
            if not JSONToken.IsArray then
                Error(ExpectedActivationsArrayErr);
            for i := 0 to JSONToken.AsArray.Count - 1 do begin
                JSONToken.AsArray.Get(i,ActivationToken);
                ActivationObject := ActivationToken.AsObject;
                Activation.Init;
                Activation."Entry No." := i + 1;
                EVALUATE(NewGuid,'{' + GetJsonToken(ActivationObject,'CompanyGUID').AsValue.AsText + '}');
                Activation."Company GUID" := NewGuid;
                Activation."Company Name" := GetJsonToken(ActivationObject,'CompanyName').AsValue.AsText;
                Activation."Company Code" := GetJsonToken(ActivationObject,'CompanyCode').AsValue.AsCode;
                Activation.Insert;
            end;
            
            
        end;
        
        
    end;
    
    
    procedure UploadCompanyInformation();
    var
        CompanyInformation: Record "Company Information";
        User: Record User;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        CompanyObject: JsonObject;
        JSONObject: JsonObject;
        JSONToken: JsonToken;
        JSONText: Text;
    begin
        CompanyInformation.Get;
        User.SetRange("User Name",UserId);
        User.FindFirst;
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        HttpHeaders.Add('Accept','application/json;charset=utf-8');
        HttpHeaders.Add('Authorization','Bearer ' + GetAccessToken);
        HttpHeaders.Add('Timeout','3000');
        if HttpContent.GetHeaders(HttpContentHeaders) then
            if HttpContentHeaders.Remove('Content-Type') then
                HttpContentHeaders.Add('Content-Type','application/json');
        JSONObject.Add('company_name',CompanyInformation.Name);
        JSONObject.Add('vat_reg_no',CompanyInformation."VAT Registration No.");
        CompanyObject.Add('address',CompanyInformation.Address);
        CompanyObject.Add('address2',CompanyInformation."Address 2");
        CompanyObject.Add('city',CompanyInformation.City);
        CompanyObject.Add('zipcode',CompanyInformation."Post Code");
        CompanyObject.Add('country',CompanyInformation."Country/Region Code");
        CompanyObject.Add('contact',CompanyInformation."Contact Person");
        JSONObject.Add('company_address',CompanyObject);
        JSONObject.Add('phone',CompanyInformation."Phone No.");
        JSONObject.Add('fax',CompanyInformation."Fax No.");
        JSONObject.Add('email',CompanyInformation."E-Mail");
        JSONObject.Add('website',CompanyInformation."Home Page");
        JSONObject.Add('user_id',User."User Name");
        JSONObject.Add('user_name',User."Full Name");
        JSONObject.Add('user_email',User."Contact Email");
        JSONObject.AsToken.WriteTo(JSONText);
        HttpContent.WriteFrom(JSONText);
        if not HttpClient.Post(Config.UploadCompanyInformationUrl,HttpContent,ResponseMessage) then
            Error(HttpRequstErr);
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error(JsonObjectExpectedErr);
        VerifyStatusOK(JSONObject);
    end;
    
    
    procedure UploadUsage();
    var
        ContiniaUsage: Record "Continia Usage";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JSONObject: JsonObject;
        UsageObject: JsonObject;
        JSONValue: JsonValue;
        JSONArray: JsonArray;
        JSONToken: JsonToken;
        JSONText: Text;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        HttpHeaders.Add('Accept','application/json;charset=utf-8');
        HttpHeaders.Add('Authorization','Bearer ' + GetAccessToken);
        HttpHeaders.Add('Timeout','3000');
        if HttpContent.GetHeaders(HttpContentHeaders) then
            if HttpContentHeaders.Remove('Content-Type') then
                HttpContentHeaders.Add('Content-Type','application/json');
        JSONObject.Add('product_id',Config.ProductID);
        JSONObject.Add('company_guid',Toolbox.GUIDtoText(Config.CompanyGUID));
        if ContiniaUsage.FindSet then
            repeat
                clear(UsageObject);
                UsageObject.Add('type',ContiniaUsage.Type);
                UsageObject.Add('user_id',ContiniaUsage."User ID");
                UsageObject.Add('timestamp',Format(ContiniaUsage.Timestamp));
                UsageObject.Add('quantity',ContiniaUsage.Quantity);
                JSONArray.Add(UsageObject);
            until ContiniaUsage.Next = 0;
        JSONObject.Add('usages',JSONArray);
        JSONObject.AsToken.WriteTo(JSONText);
        HttpContent.WriteFrom(JSONText);
        if not HttpClient.Post(Config.UsageUrl,HttpContent,ResponseMessage) then
            Error(HttpRequstErr);
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error(JsonObjectExpectedErr);
        VerifyStatusOK(JSONObject);
        ContiniaUsage.DeleteAll;
    end;
    
    
    local procedure VerifyStatusOK(JSONObject: JsonObject);
    var
        JSONToken: JsonToken;
        MsgToken: JsonToken;
        ExceptionMsg: Text;
        Msg: Text;
        ExpectedStatusOKErr: TextConst ENU='Could not connect to Continia Online.\Invalid response, expected Status = OK';
        FailedErr: TextConst ENU='The request to Continia Online failed with the following message: \%1 \%2';
        InvalidStatusErr: TextConst ENU='The request to Continia Online failed with the following message: \%1';
    begin
        if JSONObject.Get('Status',JSONToken) then begin
            if JSONToken.AsValue.AsText <> 'OK' then begin
                if JSONObject.Get('Message',MsgToken) then
                    Error(InvalidStatusErr,MsgToken.AsValue.AsText);
                Error(ExpectedStatusOKErr);
            end;
            
            
        end else begin
            Msg := GetJsonToken(JSONObject,'Message').AsValue.AsText;
            ExceptionMsg := GetJsonToken(JSONObject,'ExceptionMessage').AsValue.AsText;
            Error(FailedErr,Msg,ExceptionMsg);
        end;
        
        
    end;
    
    
    local procedure Secret(): Text;
    begin
        exit('ThisIsAVerySecretMessage');
    end;
    
    
}
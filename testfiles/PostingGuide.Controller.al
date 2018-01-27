codeunit 70000100 PostingGuide
{
    trigger OnRun();
    begin
    end;
    
    var
        myInt: Integer;
        
    procedure StartRequest(ReqGuid: Guid);
    begin
        // Start request to Continia Online API, with GUID as a parameter
        Hyperlink('https://ranavtest.azurewebsites.net/api/PostingGuideStart?code=LinaMaYrF1XlhsCZRCSTcpi9CwY/2b3tx8GLLfXyFEixc2kkB1Z0uA==&guid=' + ReqGuid);
    end;
    
    // Sending POST request to Continia Online API, with the GUID in the HttpContent
    // This function return a PostingGuideBuffer table with the posting suggestion
    procedure GetPostingSuggestion(ReqGuid: Guid; var PostingGuideBuffer: Record PostingGuideBuffer);
    var
        TempBlob: Record TempBlob temporary;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JSONObject: JsonObject;
        JSONValue: JsonValue;
        JSONArray: JsonArray;
        JSONToken: JsonToken;
        i: Integer;
        JSONText: Text;
        JsonArrayExpectedErr: TextConst
            ENU='Invalid response, expected JSON array as root object.';
        MissingEntryErr: TextConst
            ENU='Invalid response, expected posting entry';
        PostingLinesMissingErr: TextConst
            ENU='Invalid response, expected posting lines.';
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        JSONObject.Add('guid',ReqGuid);
        JSONObject.AsToken.WriteTo(JSONText);
        HttpContent.WriteFrom(JSONText);
        
        if HttpContent.GetHeaders(HttpContentHeaders) then
            if HttpContentHeaders.Remove('Content-Type') then
                HttpContentHeaders.Add('Content-Type','application/json');
                
        HttpClient.Post('https://ranavtest.azurewebsites.net/api/PostingGuideEnd?code=YYKTFGyiItmYbuPReKF9jXHWmaGo/qtBghLn3dEq0qY3ilNUUk1yCg==',
            HttpContent,
            Format('this %1, %2',
                'lol',
                '2'),
            'ere');
            
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error(JsonArrayExpectedErr);
            
        if not JSONObject.Get('postinglines',JSONToken) then
            Error(PostingLinesMissingErr);
            
        JSONArray := JSONToken.AsArray;
        
        for i := 0 to JSONArray.Count - 1 do begin
            JSONArray.Get(i,JSONToken);
            JSONObject := JSONToken.AsObject;
            
            if not JSONObject.Get('id',JSONToken) then
                Error(MissingEntryErr);
                
            PostingGuideBuffer.Init;
            PostingGuideBuffer.id := JSONToken.AsValue.AsInteger;
            PostingGuideBuffer.account := GetJsonToken(JSONObject,
                'account').AsValue.AsCode;
            PostingGuideBuffer.debit := GetJsonToken(JSONObject,
                'debit').AsValue.AsDecimal;
            PostingGuideBuffer.credit := GetJsonToken(JSONObject,
                'credit').AsValue.AsDecimal;
            PostingGuideBuffer.description := CopyStr(GetJsonToken(JSONObject,
                    'description').AsValue.AsText,
                1,
                50);
            PostingGuideBuffer.Insert;
        end;
    end;
    
    procedure InsertPostingSuggestionOnJournal(var PostingGuideBuffer: Record PostingGuideBuffer; TemplateName: Code[20]; BatchName: Code[20]);
    var
        ChartOfAccMapper: Record ChartOfAccMapper;
        GenJnlLine: Record "Gen. Journal Line";
        xGenJnlLine: Record "Gen. Journal Line";
        Balance: Decimal;
    begin
        xGenJnlLine.SetRange("Journal Template Name",TemplateName);
        xGenJnlLine.SetRange("Journal Batch Name",BatchName);
        xGenJnlLine.CalcSums("Balance (LCY)");
        Balance := xGenJnlLine."Balance (LCY)";
        
        if xGenJnlLine.FindLast then
            ;
            
        GenJnlLine."Journal Template Name" := TemplateName;
        GenJnlLine."Journal Batch Name" := BatchName;
        GenJnlLine.SetUpNewLine(xGenJnlLine,Balance,true);
        
        if PostingGuideBuffer.FindSet then
            repeat
                ChartOfAccMapper.Get(PostingGuideBuffer.account);
                
                GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(TemplateName,
                    BatchName);
                GenJnlLine.Validate("Posting Date",WorkDate);
                GenJnlLine.Validate("Account Type",
                    GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Account No.",
                    ChartOfAccMapper."G/L Account");
                GenJnlLine.Validate(Description,
                    PostingGuideBuffer.description);
                GenJnlLine.Validate("Debit Amount",
                    PostingGuideBuffer.debit);
                GenJnlLine.Validate("Credit Amount",
                    PostingGuideBuffer.credit);
                GenJnlLine.UpdateLineBalance;
                GenJnlLine.Insert(true);
                
                Balance += GenJnlLine."Balance (LCY)";
            until PostingGuideBuffer.Next = 0;
    end;
    
    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    var
        CouldNotfindTokenErr: TextConst
            Comment='%1 is the token key we are looking for',
            ENU='Invalid response, expected token with key %1';
    begin
        if not JsonObject.Get(TokenKey,JsonToken) then
            Error(CouldNotfindTokenErr,TokenKey);
    end;
}
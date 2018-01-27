codeunit 70003500 ZendeskController
{
    trigger OnRun();
    begin
        RefreshFromUrl('https://private.zendesk.com/api/v2/search.json?query=type:ticket group:"product"');
    end;
    
    var
        Depth: Integer;
        
    procedure Refresh();
    begin
        RefreshFromUrl('https://private.zendesk.com/api/v2/search.json?query=type:ticket group:"product"');
    end;
    
    procedure RefreshFromUrl(Url: Text);
    var
        TempBlob: Record TempBlob;
        ZendeskIssue: Record ZendeskIssue;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JSONObject: JsonObject;
        JSONValue: JsonValue;
        JSONArray: JsonArray;
        JSONToken: JsonToken;
        i: Integer;
        JSONText: Text;
        NextPage: Text;
        
    begin
        Depth += 1;
        TempBlob.WriteAsText('username:password',TextEncoding::UTF8);
        
        HttpClient.DefaultRequestHeaders().Add('Authorization','Basic ' + TempBlob.ToBase64String);
        if not HttpClient.Get(Url,ResponseMessage) then
            Error('Call to webservice failed');
            
        if not ResponseMessage.IsSuccessStatusCode then
            Error('The webservice returned an error message:\\' +
                'Status code: %1 ' +
                'Description: %2',
                ResponseMessage.HttpStatusCode,
                ResponseMessage.ReasonPhrase);
                
        ResponseMessage.Content.ReadAs(JSONText);
        if not JSONObject.ReadFrom(JSONText) then
            Error('Invalid response, expected JSON Array as root object');
            
        if JSONObject.Get('next_page',JSONToken) then
            NextPage := JSONToken.AsValue.AsText;
            
        if not JSONObject.Get('results',JSONToken) then
            Error('Invalid token');
            
        JSONArray := JSONToken.AsArray;
        
        for i := 0 to JSONArray.Count - 1 do begin
            JSONArray.Get(i,JSONToken);
            JSONObject := JSONToken.AsObject;
            
            if not JSONObject.Get('id',JSONToken) then
                Error('Could not find a token with key id');
                
            if not ZendeskIssue.Get(JSONToken.AsValue.AsInteger) then begin
                ZendeskIssue.Init;
                ZendeskIssue.id := JSONToken.AsValue.AsInteger;
            end;
            ZendeskIssue.subject := GetJsonToken(JSONObject,'subject').AsValue.AsText;
            // ZendeskIssue.created_at := GetJsonToken(JSONObject, 'created_at').AsValue.AsDateTime;
            ZendeskIssue.status := GetJsonToken(JSONObject,'status').AsValue.AsText;
            ZendeskIssue.requester := SelectJsonToken(JSONObject,'$.via.source.from.name');
            ZendeskIssue.request_email := SelectJsonToken(JSONObject,'$.via.source.from.address');
            ZendeskIssue.url := 'https://private.zendesk.com/agent/tickets/' + Format(ZendeskIssue.id);
            
            if not ZendeskIssue.Insert then
                ZendeskIssue.Modify;
        end;
        if Depth < 10 then
            RefreshFromUrl(NextPage);
    end;
    
    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JSONObject.Get(TokenKey,JSONToken) then
            Error('Could not find a token with key %1',TokenKey);
    end;
    
    procedure SelectJsonToken(JsonObject: JsonObject; Path: Text): Text;
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.SelectToken(Path,JsonToken) then
            exit ('N/A')
        else
            exit (JsonToken.AsValue.AsText);
    end;
}
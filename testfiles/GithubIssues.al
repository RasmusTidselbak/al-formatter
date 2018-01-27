codeunit 50002 GithubIssues
{
    trigger OnRun();
    begin
    end;
    
    procedure ShowResponse();
    var
        GithubIssue: Record GithubIssue;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        jObject: JsonObject;
        jValue: JsonValue;
        jArray: JsonArray;
        jToken: JsonToken;
        i: Integer;
        jText: Text;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Accept','application/json');
        HttpClient.Get('https://api.github.com/repos/Microsoft/AL/issues',ResponseMessage);
        
        ResponseMessage.Content.ReadAs(jText);
        
        jObject.ReadFrom(jText);
        jArray := jObject.AsToken.AsArray;
        for i := 0 to jArray.Count - 1 do begin
            jArray.Get(i,jToken);
            jObject := jToken.AsObject;
            
            GithubIssue.Init;
            GithubIssue.id := GetJsonToken(jObject,'id').AsValue.AsInteger;
            GithubIssue.title := GetJsonToken(jObject,'title').AsValue.AsText;
            GithubIssue.url := GetJsonToken(jObject,'url').AsValue.AsText;
            GithubIssue.Insert;
        end;

        Page.Run(0,GithubIssue);
    end;
    
    local procedure GetJsonToken(jObject:JsonObject;TokenKey:Text)jToken:JsonToken;
    begin
        jObject.Get(TokenKey,jToken);
    end;
}

table 50000 GithubIssue
{

    fields
    {
        field(1;id;Integer)
        {
        }
        field(2;title;Text[100]){}
        field(3;url;Text[250]){}
    }
    
    keys
    {
        key(PK;id)
        {
            Clustered = true;
        }
    }
    
    var
        myInt: Integer;
        
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

page 50001 GithubIssues
{
    PageType = Card;
    SourceTable = GithubIssue;
    
    layout
    {
        area(content)
        {
            group(GroupName)
            {
                field(ID;id)
                {
                
                }
                field(Title;title){}
                field(URL;url){}
            }
        }
    }
    
    actions
    {
        area(processing)
        {
            Action(ActionName)
            {
                trigger OnAction();
                begin
                end;
            }
        }
    }
    
    var
        myInt: Integer;
}

pageextension 50004 GithubAction extends            "Item List"
{
    layout
    {
        // Add changes to page layout here
    }
    
    actions
    {
        // Add changes to page actions here
        addlast(Item){
            Action("Show Github")
            {
                trigger OnAction();
                var
                    GithubIssues: Codeunit GithubIssues;
                begin
                    GithubIssues.ShowResponse();
                end;
            }
        }
    }
    
    var
        myInt: Integer;
}

tableextension 10000 MyExtension extends Customer
{
    fields
    {
        // Add changes to table fields here
    }
    
    var
        myInt : Integer;
}

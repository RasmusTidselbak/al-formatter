table 092190 TestIndent
{

    fields
    {
        field(1;MyField;Integer)
        {
        }
        
        field(2;City;Text[30])
        {
            TableRelation = if ("Country/Region Code"=const('')) "Post Code".City else
                if ("Country/Region Code"=filter(<>'')) "Post Code".City
                Where ("Country/Region Code"=field("Country/Region Code"));
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

    trigger OnRun(); begin end;
    
    trigger OnValidate();
    begin
        if true = false then
            Status := 1;
            
        if true and
            (Status = 2)
        then begin
            Status := 3
end else
            if true and
                (Status = 2)
                else
                    if true and
                    (Status = 2) then
                        Status := 3
                    end;
                    
            }
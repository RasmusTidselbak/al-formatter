page 70079672 "CSP Bank2 Card"
{
    trigger OnOpenPage();
    var
        myInt: Integer;
        myTxt: Text;
    begin
        if myInt > 0 then
            mytxt := StrSubstNo('The webservice returned an error message:\\' +
                'Status code: %1 ' +
                'Description: %2',
                Format(myInt),
                Format(2 + 2 + 3));
                
    end;
}

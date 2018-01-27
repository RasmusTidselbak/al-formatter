// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 50001 CustomerListExt extends "Customer List"
{
    actions
    {
        addlast("&Customer")
        {
            Action("Show Greeting")
            {
                RunObject = Codeunit HelloWorld;
                RunPageOnRec = true;
                Image = CheckDuplicates;
                PromotedCategory = Category8;
                Promoted = true;
                ApplicationArea = All;
            }
        }
    }
}

pageextension 50000 CustomerExt extends "Customer Card"
{
    actions
    {
        addlast("&Customer")
        {
            Action("Show Greeting")
            {
                RunObject = Codeunit HelloWorld;
                RunPageOnRec = true;
                Image = CheckDuplicates;
                Promoted = true;
                PromotedCategory = Category8;
                ApplicationArea = All;
            }
        }
    }
}

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50001 HelloWorld
{
    TableNo = Customer;
    
    trigger OnRun();
    var
        HelloText: Codeunit GreetingsManagement;
        str: Text;
    begin
        Message('%1, %2''x',HelloText.GetRandomGreeting(),Rec.Name);
        
        str := 'something '' is coool';
    end;
}
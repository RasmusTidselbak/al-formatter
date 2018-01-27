codeunit 70000007 "Continia Core Notification"
{
    trigger OnRun();
    var
        ContiniaCore : Codeunit "Continia Core";
    begin
    end;
    
    var
        ContiniaCore: Codeunit "Continia Core";
        ContiniaCoreConfig: Codeunit "Continia Core Config";
        ActivationMsg: TextConst ENU='Your Continia product has not been activated, your trial will expire in %1 days.',
            DAN='here';
        MyNotificationId: TextConst ENU='c32aff21-d9ca-4a96-bd8b-fd14b3c5365c';
        NotificationActionTxt: TextConst ENU='Activate';
        
    procedure RoleCenterOnOpenPage();
    var
        License: Record "Continia License" temporary;
        MyNotification: Notification;
        Handled: Boolean;
        ExpirationDate: Date;
        ExpiresIn: Integer;
        Msg: Text;
    begin
        OnBeforeContiniaCoreNotification(Handled);
        if Handled then
            exit;
            
        ContiniaCore.OnBeforeContiniaCoreStartupNotification(Handled);
        if Handled then
            exit;
            
        if ContiniaCore.HasAccessExtended(ContiniaCoreConfig.BasicGranule,License) then begin
            ExpiresIn := License."Expiration Date" - TODAY;
        end;
        
        if ExpiresIn > 30 then
            exit;
            
        if ExpiresIn < 0 then
            ExpiresIn := 0;
            
        MyNotification.Id(MyNotificationId);
        MyNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
        MyNotification.Message(STRSUBSTNO(ActivationMsg,ExpiresIn));
        MyNotification.AddAction(NotificationActionTxt,Codeunit::"Continia Core Notification",'RoleCenterOnOpenPageAction');
        MyNotification.Send;
        
        
        case name of
            statement:
                expression;
            expressoin:
                statement;
        else
            statement;
        end;
    end;
    
    procedure RoleCenterOnOpenPageAction(MyNotification: Notification); // This procedure has to be public, since the Notification Action cannot Find local functions.
    var
        something : TextConst ENU='test';
    begin
        ContiniaCore.RegisterProduct;
    end;
    
    local procedure RoleCenterOnInitPage();
    var
        ContiniaCore: Codeunit "Continia Core";
    begin
        ContiniaCore.TokenRequestAsync;
    end;
    
    [IntegrationEvent(true,true)]
    local procedure OnBeforeContiniaCoreNotification(var Handled: Boolean);
    begin
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Activities",'OnOpenPageEvent','',false,false)]
    local procedure O365ActivitiesOnOpenPageEvent(var Rec: Record "Activities Cue");
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Customer Activity Page",'OnOpenPageEvent','',false,false)]
    local procedure O365CustomerActivityOnOpenPageEvent(var Rec: Record Customer);
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Sales Activities",'OnOpenPageEvent','',false,false)]
    local procedure O365SalesActivitiesOnOpenPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"SO Processor Activities",'OnOpenPageEvent','',false,false)]
    local procedure SOProcessorActivitiesOnOpenPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"Accountant Activities",'OnOpenPageEvent','',false,false)]
    local procedure AccountantActivitiesOnOpenPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"Team Member Activities",'OnOpenPageEvent','',false,false)]
    local procedure TeamMemberActivitiesOnOpenPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"User Security Activities",'OnOpenPageEvent','',false,false)]
    local procedure UserSecurityActivitiesOnOpenPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Invoicing Activities",'OnOpenPageEvent','',false,false)]
    local procedure O365InvoicingActivitiesOnOpenPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnOpenPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Activities",'OnInitPageEvent','',false,false)]
    local procedure O365ActivitiesOnInitPageEvent(var Rec: Record "Activities Cue");
    begin
        RoleCenterOnInitPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Customer Activity Page",'OnInitPageEvent','',false,false)]
    local procedure O365CustomerActivityOnInitPageEvent(var Rec: Record Customer);
    begin
        RoleCenterOnInitPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Sales Activities",'OnInitPageEvent','',false,false)]
    local procedure O365SalesActivitiesOnInitPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnInitPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"SO Processor Activities",'OnInitPageEvent','',false,false)]
    local procedure SOProcessorActivitiesOnInitPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnInitPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"Accountant Activities",'OnInitPageEvent','',false,false)]
    local procedure AccountantActivitiesOnInitPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnInitPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"Team Member Activities",'OnInitPageEvent','',false,false)]
    local procedure TeamMemberActivitiesOnInitPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnInitPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"User Security Activities",'OnInitPageEvent','',false,false)]
    local procedure UserSecurityActivitiesOnInitPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnInitPage;
    end;
    
    [EventSubscriber(ObjectType::Page,Page::"O365 Invoicing Activities",'OnInitPageEvent','',false,false)]
    local procedure O365InvoicingActivitiesOnInitPageEvent(var Rec: Record "O365 Sales Cue");
    begin
        RoleCenterOnInitPage;
    end;
    
}
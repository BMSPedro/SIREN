pageextension 50105 "Vendor Car" extends "Vendor Card"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field("SIREN Number"; Rec."SIREN Number")
            {
                ApplicationArea = all;
                ToolTip = 'SIREN Number';
            }
        }
    }

}
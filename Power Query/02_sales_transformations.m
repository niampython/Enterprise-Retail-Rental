let
  Source = AzureStorage.Blobs("https://enterpriseretailstorage.blob.core.windows.net/retaildata"),
  Navigation = Source{[#"Folder Path" = "https://enterpriseretailstorage.blob.core.windows.net/retaildata", Name = "Sales.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Expanded Data" = Table.ExpandTableColumn(#"Imported Excel workbook", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12"}),
  #"Promoted headers" = Table.PromoteHeaders(#"Expanded Data", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"SalesLineID", type text}, {"OrderID", type text}, {"OrderDate", type text}, {"CustomerID", type text}, {"ProductID", type text}, {"StoreID", type text}, {"Quantity", type text}, {"UnitPrice", type text}, {"DiscountPct", type number}, {"PromotionID", type text}, {"SalesChannel", type text}, {"PaymentMethod", type text}}),
  #"Removed columns" = Table.RemoveColumns(#"Changed column type", {"Sales", "Sales_1", "Sheet", "false"}),
  #"OrderID update to ORD" = Table.TransformColumns(
    #"Removed columns",
    {
        {
            "OrderID",
            each
                if _ = null then
                    null
                else if
                    (
                        Text.StartsWith(_, "o")
                        or Text.StartsWith(_, "O")
                    )
                    and not Text.StartsWith(_, "ORD-")
                then
                    "ORD-" & Text.Range(_, 1)
                else
                    _,
            type text
        }
    }
),
  #"OrderDate Type Date" = Table.TransformColumns(
    #"OrderID update to ORD",
    {
        {
            "OrderDate",
            each
                if _ = null then
                    null
                else
                    try Date.From(
                        DateTime.FromText(
                            Text.From(_),
                            [Format = "MM/dd/yyyy HH:mm", Culture = "en-US"]
                        )
                    )
                    otherwise null,
            type date
        }
    }
),
  #"Quantity Invalid Values Replaced" = Table.ReplaceValue(#"OrderDate Type Date", "-", "", Replacer.ReplaceText, {"CustomerID"}),
  #"Quantity data type change" = Table.TransformColumns(
    #"Quantity Invalid Values Replaced",
    {
        {
            "Quantity",
            each
                if _ = null then
                    null
                else if Text.Lower(Text.Trim(Text.From(_))) = "two" then
                    2
                else
                    try Int64.From(_)
                    otherwise null,
            Int64.Type
        }
    }
),
  #"UnitPrice replace value and data type change" = Table.TransformColumns(
    #"Quantity data type change",
    {
        {
            "UnitPrice",
            each
                let
                    CleanValue =
                        if _ = null then
                            null
                        else
                            Text.Select(
                                Text.From(_),
                                {"0".."9", ".", "-"}
                            )
                in
                    if CleanValue = null or CleanValue = "" then
                        null
                    else
                        Number.FromText(CleanValue, "en-US"),
            type number
        }
    }
),
  #"Proper case SalesChannel" = Table.TransformColumns(#"UnitPrice replace value and data type change", {{"SalesChannel", each Text.Proper(Text.Trim(_)), type text}}),
  #"PaymentMethod standardizing" = Table.TransformColumns(
    #"Proper case SalesChannel",
    {
        {
            "PaymentMethod",
            each
                if _ = null then
                    null
                else if Text.Upper(Text.Trim(_)) = "CC" then
                    "Credit Card"
                else
                    Text.Proper(Text.Trim(_)),
            type text
        }
    }
)
in
  #"PaymentMethod standardizing"

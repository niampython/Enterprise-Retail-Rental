let
  Source = AzureStorage.Blobs("https://enterpriseretailstorage.blob.core.windows.net/retaildata"),
  Navigation = Source{[#"Folder Path" = "https://enterpriseretailstorage.blob.core.windows.net/retaildata", Name = "Returns.csv"]}[Content],
  #"Imported CSV" = Csv.Document(Navigation, [Delimiter = ",", Columns = 8, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Changed column type" = Table.TransformColumnTypes(#"Imported CSV", {{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true]),
  #"Removed duplicates" = Table.Distinct(#"Promoted headers", {"ReturnID"}),
  #"Fix OrderID" = Table.TransformColumns(
    #"Removed duplicates",
    {
        {
            "OrderID",
            each
                if _ = null then
                    null
                else if Text.StartsWith(_, "O", Comparer.OrdinalIgnoreCase)
                    and not Text.StartsWith(_, "ORD-", Comparer.OrdinalIgnoreCase) then
                    "ORD-" & Text.Range(_, 1)
                else
                    _,
            type text
        }
    }
),
  #"Change data type date" = Table.TransformColumns(#"Fix OrderID", {{"ReturnDate", each try Date.From(_) otherwise null, type date}}),
  #"Change data type ReturnQty Int" = Table.TransformColumns(#"Change data type date", {{"ReturnQty", each if _ = "one" then 1 else _, type text}}),
  #"ReturnQty data type change" = Table.TransformColumns(
    #"Change data type ReturnQty Int",
    {
        {
            "ReturnQty",
            each try Number.From(_) otherwise null,
            type number
        }
    }
),
  #"Proper case ReturnReason" = Table.TransformColumns(#"ReturnQty data type change", {{"ReturnReason", each Text.Proper(Text.Trim(_))}}),
  ReasonStatus = Table.TransformColumns(#"Proper case ReturnReason", {{"ReturnStatus",each Text.Proper(Text.Trim(_))}}),
  #"Changed column type 1" = Table.TransformColumnTypes(ReasonStatus, {{"ReturnStatus", type text}, {"ReturnReason", type text}, {"ReturnQty", Int64.Type}})
in
  #"Changed column type 1"

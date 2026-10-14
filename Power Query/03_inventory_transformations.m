let
  Source = AzureStorage.Blobs("https://enterpriseretailstorage.blob.core.windows.net/retaildata"),
  Navigation = Source{[#"Folder Path" = "https://enterpriseretailstorage.blob.core.windows.net/retaildata", Name = "Inventory.csv"]}[Content],
  #"Imported CSV" = Csv.Document(Navigation, [Delimiter = ",", Columns = 7, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"SnapshotDate", type date}, {"StoreID", type text}, {"ProductID", type text}, {"OnHandQty", type text}, {"ReorderPoint", type text}, {"LeadTimeDays", type text}, {"ABCClass", type text}}),
  #"Data type change OnHandQty" = Table.TransformColumns(
    #"Changed column type",
    {
        {"OnHandQty", each try Number.FromText(Text.Trim(Text.From(_))) otherwise null, type number}
    }
),
  #"Data type change ReorderPoint" = Table.TransformColumns(
    #"Data type change OnHandQty",
    {
        {"ReorderPoint", each try Number.FromText(Text.Trim(Text.From(_))) otherwise null, Int64.Type}
    }
),
  #"Replaced value" = Table.ReplaceValue(#"Data type change ReorderPoint", "days", "", Replacer.ReplaceText, {"LeadTimeDays"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Replaced value", {{"LeadTimeDays", Int64.Type}, {"OnHandQty", Int64.Type}})
in
  #"Changed column type 1"

let
  Source = AzureStorage.Blobs("https://enterpriseretailstorage.blob.core.windows.net/retaildata"),
  Navigation = Source{[#"Folder Path" = "https://enterpriseretailstorage.blob.core.windows.net/retaildata", Name = "Stores.csv"]}[Content],
  #"Imported CSV" = Csv.Document(Navigation, [Delimiter = ",", Columns = 9, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"StoreID", type text}, {"StoreName", type text}, {"Region", type text}, {"State", type text}, {"City", type text}, {"Address", type text}, {"ZipCode", Int64.Type}, {"OpenDate", type date}, {"Status", type text}}),
  #"Removed duplicates" = Table.Distinct(#"Changed column type", {"StoreID"}),
  #"Proper State" = Table.TransformColumns(#"Removed duplicates", {{"Region", each Text.Proper(Text.Trim(_))}}),
  Custom = Table.TransformColumns(#"Proper State", {{"City", each Text.Proper(Text.Trim(_))}}),
  #"Changed column type 1" = Table.TransformColumnTypes(Custom, {{"ZipCode", type text}, {"Region", type text}, {"City", type text}})
in
  #"Changed column type 1"

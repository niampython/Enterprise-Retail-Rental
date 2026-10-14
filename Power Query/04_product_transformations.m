let
  Source = AzureStorage.Blobs("https://enterpriseretailstorage.blob.core.windows.net/retaildata"),
  Navigation = Source{[#"Folder Path" = "https://enterpriseretailstorage.blob.core.windows.net/retaildata", Name = "Product_Master.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Expanded Data" = Table.ExpandTableColumn(#"Imported Excel workbook", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded Data", {"Name"}),
  #"Promoted headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"ProductID", type text}, {"ProductName", type text}, {"Category", type text}, {"Brand", type text}, {"UnitCost", type text}, {"ListPrice", type number}, {"Status", type text}, {"LaunchDate", type date}}),
  #"Replaced value" = Table.ReplaceValue(#"Changed column type", "$", "", Replacer.ReplaceText, {"UnitCost"}),
  #"Product Name Standardizing" = Table.TransformColumns(#"Replaced value", {{"ProductName", each Text.Proper(Text.Trim(_)), type text}}),
  #"Category Name Standardizing" = Table.TransformColumns(#"Product Name Standardizing", {{"Category", each Text.Proper(Text.Trim(_)), type text}}),
  Custom = Table.TransformColumns(#"Category Name Standardizing", {{"UnitCost", each if _ = "N/A" then "" else _, type number}}),
  #"Removed columns 1" = Table.RemoveColumns(Custom, {"Products", "Sheet", "false"}),
  #"Custom 1" = Table.TransformColumns(#"Removed columns 1", {{"UnitCost",each try Number.From(_) otherwise null, type number}}),
  #"Removed duplicates" = Table.Distinct(#"Custom 1", {"ProductID"})
in
  #"Removed duplicates"

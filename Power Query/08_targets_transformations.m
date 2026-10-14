let
  Source = AzureStorage.Blobs("https://enterpriseretailstorage.blob.core.windows.net/retaildata"),
  Navigation = Source{[#"Folder Path" = "https://enterpriseretailstorage.blob.core.windows.net/retaildata", Name = "Targets.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Expanded Data" = Table.ExpandTableColumn(#"Imported Excel workbook", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5"}, {"Column1", "Column2", "Column3", "Column4", "Column5"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded Data", {"Name", "Item", "Kind", "Hidden"}),
  #"Promoted headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars = true]),
  #"Custom 2" = Table.ReplaceValue(
    #"Promoted headers",
    each [TargetMonth],
    each
        if [TargetMonth] = "01-02-2026"
            and [Region] = "West"
        then
            "02/01/2026"
        else
            [TargetMonth],
    Replacer.ReplaceValue,
    {"TargetMonth"}
),
  #"Changed column type" = Table.TransformColumnTypes(#"Custom 2", {{"TargetMonth", type date}, {"Region", type text}, {"RevenueTarget", type number}, {"MarginTargetPct", type text}, {"OrderTarget", type text}}),
  #"Region standardized" = Table.TransformColumns(#"Changed column type", {{"Region", each Text.Proper(Text.Trim(_)), type text}}),
  #"Replaced value" = Table.ReplaceValue(#"Region standardized", "orders", "", Replacer.ReplaceText, {"OrderTarget"}),
  Custom = Table.TransformColumns(
    #"Replaced value",
    {
        {
            "MarginTargetPct",
            each
                if _ = null then
                    null
                else if Text.Contains(
                    Text.Lower(Text.From(_)),
                    "percent"
                ) or Text.Contains(
                    Text.From(_),
                    "%"
                ) then
                    let
                        CleanValue =
                            Text.Trim(
                                Text.Replace(
                                    Text.Replace(
                                        Text.Lower(Text.From(_)),
                                        "percent",
                                        ""
                                    ),
                                    "%",
                                    ""
                                )
                            )
                    in
                        try Number.From(CleanValue) / 100
                        otherwise null
                else
                    _,
            type number
        }
    }
),
  #"Changed column type 1" = Table.TransformColumnTypes(Custom, {{"OrderTarget", Int64.Type}}),
  #"Custom 1" = Table.TransformColumns(#"Changed column type 1", {{"MarginTargetPct", each try Number.From(_) otherwise null}}),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Custom 1", {{"MarginTargetPct", type number}})
in
  #"Changed column type 2"

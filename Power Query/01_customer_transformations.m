let
  Source = AzureStorage.Blobs("https://enterpriseretailstorage.blob.core.windows.net/retaildata"),
  Navigation = Source{[#"Folder Path" = "https://enterpriseretailstorage.blob.core.windows.net/retaildata", Name = "Customers.xlsx"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Expanded Data" = Table.ExpandTableColumn(#"Imported Excel workbook", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded Data", {"Name"}),
  #"Promoted headers" = Table.PromoteHeaders(#"Removed columns", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"CustomerID", type text}, {"CustomerName", type text}, {"Email", type text}, {"Segment", type text}, {"Region", type text}, {"State", type text}, {"City", type text}, {"SignupDate", type text}, {"Status", type text}}),
  #"Replaced value" = Table.TransformColumns(
        #"Changed column type",
        {
            {
                "CustomerName",
                each
                    if _ = null then
                        null
                    else if Text.Contains(_, ",") then
                        let
                            Parts = Text.Split(_, ","),
                            LastName = Text.Proper(Text.Trim(Parts{0})),
                            FirstMiddle = Text.Proper(Text.Trim(Parts{1})),

                            Words = List.Select(
                                Text.Split(FirstMiddle, " "),
                                each _ <> ""
                            ),

                            WordCount = List.Count(Words),

                            FirstName =
                                if WordCount >= 1 then Words{0}
                                else "",

                            MiddleInitial =
                                if WordCount >= 2 then
                                    Text.Start(
                                        Text.Remove(Words{1}, "."),
                                        1
                                    ) & "."
                                else
                                    null
                        in
                            if MiddleInitial = null then
                                FirstName & " " & LastName
                            else
                                FirstName & " " & MiddleInitial & " " & LastName
                    else
                        Text.Proper(Text.Trim(_)),
                type text
            }
        }
    ),
  #"Replaced value 1" = 
    Table.TransformColumns(
    #"Replaced value",
    {
        {
            "Segment",
            each
                if _ = null then
                    null
                else
                    let
                        CleanSegment = Text.Lower(Text.Trim(_))
                    in
                        if CleanSegment = "smb" then
                            "Small Business"
                        else if CleanSegment = "corp" then
                            "Corporate"
                        else
                            Text.Proper(Text.Trim(_)),
            type text
        }
    }
),
  #"Replaced value 2" = Table.ReplaceValue(#"Replaced value 1", "-", "", Replacer.ReplaceText, {"CustomerName"}),
  #"Replaced value 3" = Table.ReplaceValue(#"Replaced value 2", "Moved", "", Replacer.ReplaceText, {"CustomerName"}),
  #"Removed columns 1" = 
    
    
    Table.TransformColumns(
        #"Replaced value 3",
        {
            {
                "Region",
                each
                    if _ = null then
                        null
                    else
                        let
                            CleanRegion = Text.Lower(Text.Trim(_))
                        in
                            if CleanRegion = "south east" or CleanRegion = "southeast" then
                                "Southeast"
                            else
                                Text.Proper(Text.Trim(_)),
                type text
            }
        }
    ),
  UpperCaseStates = Table.TransformColumns(#"Removed columns 1", {{"State", each Text.Upper(_), type text}}),
  ProperCity = Table.TransformColumns(UpperCaseStates, {{"City", each Text.Proper(Text.Trim(_)), type text}}),
  StandardizeSignUpDate = 
    Table.TransformColumns(
        ProperCity,
        {
            {
                "SignupDate",
                each
                    if _ = null or Text.Trim(_) = "" then
                        null
                    else
                        try Date.FromText(Text.Trim(_), [Format="yyyy-MM-dd"])
                        otherwise
                        try Date.FromText(Text.Trim(_), [Format="dd-MMM-yyyy", Culture="en-US"])
                        otherwise
                        try Date.FromText(Text.Trim(_), [Culture="en-US"])
                        otherwise
                            _
            }
        }
    ),
  ProperTrimStatus = Table.TransformColumns(StandardizeSignUpDate, {{"Status", each Text.Proper(Text.Trim(_)), type text}}),
  #"Removed columns 2" = Table.RemoveColumns(ProperTrimStatus, {"Customers", "Sheet", "false"}),
  ChangedDateType = Table.TransformColumns(
    #"Removed columns 2",
    {
        {
            "SignupDate",
            each try Date.From(_) otherwise null,
            type date
        }
    }
),
  #"Removed blank rows" = Table.SelectRows(ChangedDateType, each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
  #"Replaced value 4" = Table.ReplaceValue(#"Removed blank rows", "-", "", Replacer.ReplaceText, {"CustomerID"}),
  #"Removed duplicates" = Table.Distinct(#"Replaced value 4", {"CustomerID"})
in
  #"Removed duplicates"

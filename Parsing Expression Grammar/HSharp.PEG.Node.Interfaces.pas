unit HSharp.PEG.Node.Interfaces;

interface

uses
  System.RegularExpressions,
  System.Rtti,
  HSharp.Collections.Interfaces;

type
  INode = interface
    ['{7F8983C7-D49A-4B8F-9696-B1EA19909452}']
    { property accessors }
    function GetValue: TValue;
    procedure SetValue(const aValue: TValue);
    function GetText: string;
    function GetIndex: Integer;
    function GetChildren: IList<INode>;
    function ToString(aLevel: Integer = 0): string;
    { properties }
    property Value: TValue read GetValue write SetValue;
    property Text: string read GetText;
    property Index: Integer read GetIndex;
    property Children: IList<INode> read GetChildren;
  end;

  IRegexNode = interface(INode)
    ['{136B89D9-EBDB-4E6C-A116-7A88D1E59DB0}']
    { property accessors }
    function GetMatch: TMatch;
    { properties }
    property Match: TMatch read GetMatch;
  end;

implementation

end.

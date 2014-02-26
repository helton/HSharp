unit HSharp.PEG.Node.Interfaces;

interface

uses
  System.Rtti,
  HSharp.Collections.Interfaces;

type
  INode = interface
    ['{7F8983C7-D49A-4B8F-9696-B1EA19909452}']
    { property accessors }
    function GetValue: TValue;
    function GetText: string;
    function GetIndex: Integer;
    function GetChildren: IList<INode>;
    { properties }
    property Value: TValue read GetValue;
    property Text: string read GetText;
    property Index: Integer read GetIndex;
    property Children: IList<INode> read GetChildren;
  end;

implementation

end.

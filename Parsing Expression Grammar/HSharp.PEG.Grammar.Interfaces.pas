unit HSharp.PEG.Grammar.Interfaces;

interface

uses
  System.Rtti,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule.Interfaces;

type
  IGrammar = interface
    ['{E1A9FA2D-86A4-4EEB-969A-0DE8C36848FF}']
    function Parse(const aText: string): INode;
    function ParseAndVisit(const aText: string): TValue;
    function AsString: string;
  end;

implementation

end.
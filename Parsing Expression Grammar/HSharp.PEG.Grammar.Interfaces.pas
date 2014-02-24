unit HSharp.PEG.Grammar.Interfaces;

interface

uses
  HSharp.PEG.Rule.Interfaces;

type
  IGrammar = interface
    ['{E1A9FA2D-86A4-4EEB-969A-0DE8C36848FF}']
    function Parse(const aText: string): Boolean;
    function AsString: string;
  end;

implementation

end.
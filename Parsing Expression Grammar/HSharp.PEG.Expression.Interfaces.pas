unit HSharp.PEG.Expression.Interfaces;

interface

uses
  HSharp.PEG.Context.Interfaces;

type
  IExpression = interface
    ['{62F4F422-597B-4B06-AED9-109236BCF845}']
    function IsMatch(const aContext: IContext): Boolean;
    procedure Match(const aContext: IContext);
    function GetText: string;
    property Text: string read GetText;
    function AsString: string;
  end;

implementation

end.

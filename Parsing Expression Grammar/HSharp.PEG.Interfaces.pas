unit HSharp.PEG.Context.Interfaces;

interface

type
  IContext = interface
    ['{BCCB62C1-06A3-4678-8D53-0A030952FC81}']
    procedure IncIndex(aOffset: Integer);
    procedure SaveState;
    procedure RestoreState;
    { Property accessors }
    function GetIndex: Integer;
    function GetText: string;
    { Properties }
    property Index: Integer read GetIndex;
    property Text: string read GetText;
  end;

implementation

end.

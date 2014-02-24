unit HSharp.Core.Types;

interface

type
  TTextPosition = record
    Line, Column: Integer;
    function ToString: String;
  end;

implementation

uses
  System.SysUtils;

{ TTextPosition }

function TTextPosition.ToString: String;
begin
  Result := '[' + Line.ToString + ', ' + Column.ToString + ']';
end;

end.

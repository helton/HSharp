unit HSharp.Core.ArrayString;

interface

uses
  System.Types,
  HSharp.Core.Arrays;

type
  IArrayString = interface(IArray<String>)
    ['{F2ABB719-B7B2-42DC-B398-5556F8672585}']
    function AsString: string;
    procedure Indent(aLevel: Integer);
    function Join(aSeparator: string): string;
  end;

  TArrayString = class(TArray<string>, IArrayString)
  public
    function AsString: string;
    procedure Indent(aLevel: Integer);
    function Join(aSeparator: string): string;
  end;

implementation

uses
  System.SysUtils;

{ TArrayString }

function TArrayString.AsString: string;
begin
  Result := Join(sLineBreak);
end;

procedure TArrayString.Indent(aLevel: Integer);
const
  iSpacedPerLevel = 4;
begin
  Map(
    function (const aItem: string): string
    begin
      Result := StringOfChar(' ', aLevel * iSpacedPerLevel) + aItem;
    end
  );
end;

function TArrayString.Join(aSeparator: string): string;
var
  Text: string;
begin
  Text := '';
  ForEach(
    procedure (const aItem: string)
    begin
      if Text.IsEmpty then
        Text := aItem
      else
        Text := Text + aSeparator + aItem;
    end
  );
  Result := Text;
end;

end.

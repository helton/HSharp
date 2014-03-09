{***************************************************************************}
{                                                                           }
{           HSharp Framework for Delphi                                     }
{                                                                           }
{           Copyright (C) 2014 Helton Carlos de Souza                       }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit HSharp.Core.ArrayString;

interface

uses
  System.Types,
  HSharp.Core.Arrays;

type
  IArrayString = interface(IArray<string>)
    ['{F2ABB719-B7B2-42DC-B398-5556F8672585}']
    procedure AddFormatted(const aItem: string; const aArgs: array of const);
    function AsString: string;
    function Contains(const aItem: string): Boolean; {TODO -oHelton -cMove : Move to Array (use Generics.Defaults Equality interfaces to compare with generic)}
    procedure Indent(aLevel: Integer);
    function Join(aSeparator: string): string;
  end;

  TArrayString = class(TArray<string>, IArrayString)
  public
    procedure AddFormatted(const aItem: string; const aArgs: array of const);
    function AsString: string;
    function Contains(const aItem: string): Boolean;
    procedure Indent(aLevel: Integer);
    function Join(aSeparator: string): string;
  end;

implementation

uses
  System.SysUtils;

{ TArrayString }

procedure TArrayString.AddFormatted(const aItem: string; const aArgs: array of const);
begin
  Add(Format(aItem, aArgs));
end;

function TArrayString.AsString: string;
begin
  Result := Join(sLineBreak);
end;

function TArrayString.Contains(const aItem: string): Boolean;
var
  Found: Boolean;
begin
  Found := False;
  ForEach(
    procedure (const aCurrentItem: string)
    begin
      if not Found then
        Found := SameText(aItem, aCurrentItem);
    end
  );
  Result := Found;
end;

procedure TArrayString.Indent(aLevel: Integer);
const
  iSpacesPerLevel = 2;
begin
  Map(
    function (const aItem: string): string
    begin
      Result := StringOfChar(' ', aLevel * iSpacesPerLevel) + aItem;
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

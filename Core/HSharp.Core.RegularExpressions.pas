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

unit HSharp.Core.RegularExpressions;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.RegularExpressions,
  System.RegularExpressionsCore,
  HSharp.Core.Types;

type
  TRegExHelper = record helper for TRegEx
    function GetPerlRegEx: TPerlRegEx;
    function GetPattern: String;
    function GetInput: String;
    function GetOptions: TRegExOptions;
  end;

  TMatchHelper = record helper for TMatch
    function GetPerlRegEx: TPerlRegEx;
    function GetTextPosition: TTextPosition;
  end;

  TGroupHelper = record helper for TGroupCollection
    function GetPerlRegEx: TPerlRegEx;
    function GetTextPosition(AGroup: TGroup): TTextPosition;
  end;

  function GetTextPositionByAbsoluteIndex(AText: String; AAbsoluteIndex: Integer): TTextPosition;

implementation

function GetTextPositionByAbsoluteIndex(AText: String; AAbsoluteIndex: Integer): TTextPosition;
var
  TextAsArray: TArray<String>;
  Line: String;
  LineNumber, CurrentIndex, NextIndex: Integer;
begin
  TextAsArray  := AText.Replace(sLineBreak, #$A).Split([#$A]);
  CurrentIndex := 0;
  LineNumber   := 1;
  for Line in TextAsArray do
  begin
    NextIndex := CurrentIndex + Line.Length;
    if (AAbsoluteIndex >= CurrentIndex) and
       (AAbsoluteIndex <= NextIndex) then
    begin
      Result.Line   := LineNumber;
      Result.Column := AAbsoluteIndex - CurrentIndex;
      Break;
    end;
    CurrentIndex := NextIndex + Length(sLineBreak);
    if CurrentIndex > AAbsoluteIndex then {next position is a sLineBreak }
    begin
      Result.Line   := LineNumber;
      Result.Column := AAbsoluteIndex;
      Break;
    end;
    Inc(LineNumber);
  end;
end;

function InternalGetPerlRegEx(ATypeInfo, AInstance: Pointer): TPerlRegEx;
var
  RttiField: TRttiField;
  Value: TValue;
begin
  RttiField := TRttiContext.Create.GetType(ATypeInfo).GetField('FRegEx');
  if Assigned(RttiField) then
  begin
    Value := RttiField.GetValue(AInstance);
    Value.TryAsType<TPerlRegEx>(Result);
  end;
end;

function InternalGetPerlRegExFromNotifier(ATypeInfo, AInstance: Pointer): TPerlRegEx;
var
  RttiField: TRttiField;
  Value: TValue;
  InterfaceReference: IInterface;
begin
  Result    := nil;
  RttiField := TRttiContext.Create.GetType(ATypeInfo).GetField('FNotifier');
  if Assigned(RttiField) then
  begin
    Value := RttiField.GetValue(AInstance);
    Value.TryAsType<IInterface>(InterfaceReference);
    if Assigned(InterfaceReference) then
      Result := InternalGetPerlRegEx(TInterfacedObject(InterfaceReference).ClassInfo,
                                     TInterfacedObject(InterfaceReference));
  end;
end;

{ TRegExHelper }

function TRegExHelper.GetInput: String;
var
  PerlRegEx: TPerlRegEx;
begin
  PerlRegEx := GetPerlRegEx;
  if Assigned(PerlRegEx) then
    Result := PerlRegEx.Subject;
end;

function TRegExHelper.GetOptions: TRegExOptions;
var
  RttiField: TRttiField;
  Value: TValue;
begin
  RttiField := TRttiContext.Create.GetType(TypeInfo(TRegEx)).GetField('FOptions');
  if Assigned(RttiField) then
  begin
    Value := RttiField.GetValue(@Self);
    Value.TryAsType<TRegExOptions>(Result);
  end;
end;

function TRegExHelper.GetPattern: String;
var
  PerlRegEx: TPerlRegEx;
begin
  PerlRegEx := GetPerlRegEx;
  if Assigned(PerlRegEx) then
    Result := PerlRegEx.RegEx;
end;

function TRegExHelper.GetPerlRegEx: TPerlRegEx;
begin
  Result := InternalGetPerlRegEx(TypeInfo(TRegEx), @Self);
end;

{ TMatchHelper }

function TMatchHelper.GetPerlRegEx: TPerlRegEx;
begin
  Result := InternalGetPerlRegExFromNotifier(TypeInfo(TMatch), @Self);
end;

function TMatchHelper.GetTextPosition: TTextPosition;
begin
  Result := GetTextPositionByAbsoluteIndex(GetPerlRegEx.Subject, Self.Index);
end;

{ TGroupHelper }

function TGroupHelper.GetPerlRegEx: TPerlRegEx;
begin
  Result := InternalGetPerlRegExFromNotifier(TypeInfo(TGroupCollection), @Self);
end;

function TGroupHelper.GetTextPosition(AGroup: TGroup): TTextPosition;
begin
  Result := GetTextPositionByAbsoluteIndex(GetPerlRegEx.Subject, AGroup.Index);
end;

end.


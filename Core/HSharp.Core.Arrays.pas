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

unit HSharp.Core.Arrays;

interface

type
  TForEachProc<T> = reference to procedure (const aItem: T);
  TForEachProcIndex<T> = reference to procedure (const aItem: T; AIndex: Integer);
  TMapFunc<T> = reference to function (const aItem: T): T;
  TMapFuncIndex<T> = reference to function (const aItem: T; aIndex: Integer): T;
  TReduceFunc<T> = reference to function (const aLeft, aRight: T): T;
  TSortFunc<T> = reference to function (const aLeft, aRight: T): Integer;

  IArray<T> = interface
    ['{B434E9EC-1F8E-46CD-A055-8829C095ADCC}']
    function GetItem(aIndex: Integer): T;
    procedure SetItem(aIndex: Integer; const AValue: T);

    procedure Add(const aItem: T);
    procedure AddRange(const aItems: array of T);
    function Clone: IArray<T>;
    function Count: Integer;
    function First: T;
    procedure ForEach(aForEachProc: TForEachProc<T>);
    procedure ForEachIndex(aForEachProcIndex: TForEachProcIndex<T>);
    function Head: T;
    function Init: IArray<T>;
    property Items[aIndex: Integer]: T read GetItem write SetItem; default;
    function Last: T;
    function Length: Integer;
    procedure Map(aMapFunc: TMapFunc<T>);
    procedure MapIndex(aMapFuncIndex: TMapFuncIndex<T>);
    function Reduce(aReduceFunc: TReduceFunc<T>): T;
    function Remove(aIndex: Integer): T;
    function Reverse: IArray<T>;
    procedure Sort(aSortFunc: TSortFunc<T>; aReverse: Boolean = False);
    function Sorted(aSortFunc: TSortFunc<T>; aReverse: Boolean = False): IArray<T>;
    function Tail: IArray<T>;
  end;

  TArray<T> = class(TInterfacedObject, IArray<T>)
  strict private
    FItems: System.TArray<T>;
    function GetItem(aIndex: Integer): T;
    procedure SetItem(aIndex: Integer; const aValue: T);
    procedure Swap(var aLeft, aRight: T);
  public
    procedure Add(const aItem: T);
    procedure AddRange(const aItems: array of T);
    function Clone: IArray<T>;
    function Count: Integer;
    function First: T;
    procedure ForEach(aForEachProc: TForEachProc<T>);
    procedure ForEachIndex(aForEachProcIndex: TForEachProcIndex<T>);
    function Head: T;
    function Init: IArray<T>;
    property Items[aIndex: Integer]: T read GetItem write SetItem;
    function Last: T;
    function Length: Integer;
    procedure Map(aMapFunc: TMapFunc<T>);
    procedure MapIndex(aMapFuncIndex: TMapFuncIndex<T>);
    function Reduce(aReduceFunc: TReduceFunc<T>): T;
    function Remove(aIndex: Integer): T;
    function Reverse: IArray<T>;
    procedure Sort(aSortFunc: TSortFunc<T>; aReverse: Boolean = False);
    function Sorted(aSortFunc: TSortFunc<T>; aReverse: Boolean = False): IArray<T>;
    function Tail: IArray<T>;
    constructor Create(const aItems: System.TArray<T>); overload;
  end;

implementation

{ TArray<T> }

procedure TArray<T>.Add(const aItem: T);
begin
  SetLength(FItems, System.Length(FItems) + 1);
  FItems[High(FItems)] := aItem;
end;

procedure TArray<T>.AddRange(const aItems: array of T);
var
  Item: T;
begin
  for Item in aItems do
    Add(Item);
end;

function TArray<T>.Clone: IArray<T>;
var
  Item: T;
begin
  for Item in FItems do
    Result.Add(Item);
end;

function TArray<T>.Count: Integer;
begin
  Result := Length;
end;

constructor TArray<T>.Create(const aItems: System.TArray<T>);
begin
  FItems := aItems;
end;

function TArray<T>.First: T;
begin
  Result := Head;
end;

procedure TArray<T>.ForEach(aForEachProc: TForEachProc<T>);
var
  Item: T;
begin
  for Item in FItems do
    aForEachProc(Item);
end;

procedure TArray<T>.ForEachIndex(aForEachProcIndex: TForEachProcIndex<T>);
var
  i: Integer;
begin
  for i := Low(FItems) to High(FItems) do
    aForEachProcIndex(FItems[i], i);
end;

function TArray<T>.GetItem(aIndex: Integer): T;
begin
  Result := FItems[aIndex];
end;

function TArray<T>.Head: T;
begin
  Result := FItems[0];
end;

function TArray<T>.Init: IArray<T>;
begin
  Result := Clone;
  Result.Remove(Count - 1);
end;

function TArray<T>.Last: T;
begin
  Result := FItems[High(FItems)];
end;

function TArray<T>.Length: Integer;
begin
  Result := High(FItems) + 1;
end;

procedure TArray<T>.Map(aMapFunc: TMapFunc<T>);
var
  i: Integer;
begin
  for i := Low(FItems) to High(FItems) do
    FItems[i] := aMapFunc(FItems[i]);
end;

procedure TArray<T>.MapIndex(aMapFuncIndex: TMapFuncIndex<T>);
var
  i: Integer;
begin
  for i := Low(FItems) to High(FItems) do
    FItems[i] := aMapFuncIndex(FItems[i], i);
end;

function TArray<T>.Reduce(aReduceFunc: TReduceFunc<T>): T;
var
  I: Integer;
begin
  Result := Head;
  for i := Low(FItems) + 1 to High(FItems) do
    Result := aReduceFunc(Result, FItems[i]);
end;

function TArray<T>.Remove(aIndex: Integer): T;
var
  Current: T;
  i: Integer;
begin
  Result := GetItem(aIndex);
  for i := aIndex to High(FItems) - 1 do
    FItems[i] := FItems[i + 1];
  SetLength(FItems, System.Length(FItems) - 1);
end;

function TArray<T>.Reverse: IArray<T>;
var
  i: Integer;
begin
  for i := High(FItems) downto Low(FItems) do
    Result.Add(FItems[i]);
end;

procedure TArray<T>.SetItem(aIndex: Integer; const aValue: T);
begin
  FItems[aIndex] := aValue;
end;

procedure TArray<T>.Sort(aSortFunc: TSortFunc<T>; aReverse: Boolean);
var
  I: Integer;
  SortResult: Integer;
begin
  for i := Low(FItems) to High(FItems) - 1 do
  begin
    SortResult := aSortFunc(FItems[i], FItems[i + 1]);
    if SortResult <> 0 then
    begin
      if SortResult > 0 then
        Swap(FItems[i], FItems[i + 1]);
    end;
  end;
  if aReverse then
    Reverse;
end;

function TArray<T>.Sorted(aSortFunc: TSortFunc<T>; aReverse: Boolean): IArray<T>;
begin
  Result := Clone;
  Result.Sort(aSortFunc, aReverse);
end;

procedure TArray<T>.Swap(var aLeft, aRight: T);
var
  Temp: T;
begin
  Temp   := aLeft;
  aLeft  := aRight;
  aRight := Temp;
end;

function TArray<T>.Tail: IArray<T>;
begin
  Result := Clone;
  Result.Remove(0);
end;

end.

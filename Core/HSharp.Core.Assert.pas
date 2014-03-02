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

unit HSharp.Core.Assert;

interface

uses
  System.SysUtils;

type
  EUnitTestException = class(Exception);

  Assert = class
  private
    class function Compare<T>(const aLeft, aRight: T): Boolean; static;
    class procedure Fail<T>(const aLeft, aRight: T; aMessage: string = ''); overload; static; 
    class procedure Fail<T>(aMessage: string = ''); overload; static;  
  public
    class procedure AreEqual<T>(const aLeft, aRight: T; aMessage: string = ''); static;
    class procedure AreNotEqual<T>(const aLeft, aRight: T; aMessage: string = ''); static;
    class procedure AreNotSame(const aLeft, aRight: TObject; aMessage: string = ''); overload; static;
    class procedure AreNotSame(const aLeft, aRight: IInterface; aMessage: string = ''); overload; static;
    class procedure AreSame(const aLeft, aRight: TObject; aMessage: string = ''); overload; static;
    class procedure AreSame(const aLeft, aRight: IInterface; aMessage: string = ''); overload; static;
    class procedure IsFalse(aCondition: Boolean; aMessage: string = ''); static;
    class procedure IsTrue(aCondition: Boolean; aMessage: string = ''); static;
    class procedure WillRaiseException(aProc: TProc; aExceptionClass: ExceptClass; aMessage: string = ''); static;
  end;

implementation

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Rtti,
  System.StrUtils;

{ Assert }

class procedure Assert.AreEqual<T>(const aLeft, aRight: T;
  aMessage: string);
begin
  if not Compare(aLeft, aRight) then
    Fail<T>(ALeft, aRight, aMessage);
end;

class procedure Assert.AreNotEqual<T>(const aLeft, aRight: T;
  aMessage: string);
begin
  if Compare(aLeft, aRight) then
    Fail<T>(aLeft, aRight, aMessage);
end;

class procedure Assert.AreNotSame(const aLeft, aRight: TObject;
  aMessage: string);
begin
  if aLeft.Equals(aRight) then
    Fail<TObject>(aLeft, aRight, aMessage);
end;

class procedure Assert.AreNotSame(const aLeft, aRight: IInterface;
  aMessage: string);
begin
  if aLeft = aRight then
    Fail<IInterface>(aLeft, aRight, aMessage);
end;

class procedure Assert.AreSame(const aLeft, aRight: TObject;
  aMessage: string);
begin
  if not aLeft.Equals(aRight) then
    Fail<TObject>(aLeft, aRight, aMessage);
end;

class procedure Assert.AreSame(const aLeft, aRight: IInterface;
  aMessage: string);
begin
  if aLeft <> aRight then
    Fail<IInterface>(aLeft, aRight, aMessage);
end;

class procedure Assert.IsFalse(aCondition: Boolean; aMessage: string);
begin
  if aCondition then
    Fail<Boolean>(False, True, aMessage);
end;

class procedure Assert.IsTrue(aCondition: Boolean;
  aMessage: string);
begin
  if not aCondition then
    Fail<Boolean>(True, False, aMessage);
end;

class procedure Assert.WillRaiseException(aProc: TProc;
  aExceptionClass: ExceptClass; aMessage: string);
begin
  try
    AProc;
  except
    on E: Exception do
    begin
      if not (E is aExceptionClass) then
        Fail<String>(E.ClassName, aExceptionClass.ClassName);
    end;           
  end;
  Fail<String>(('None exception was raised. Expected exception <' + aExceptionClass.ClassName + '>' +
                sLineBreak + aMessage).Trim);  
end;

class function Assert.Compare<T>(const aLeft, aRight: T): Boolean;
begin
  Result := TEqualityComparer<T>.Default.Equals(aLeft, aRight);
end;

class procedure Assert.Fail<T>(aMessage: string);
begin
  try
    raise EUnitTestException.Create(aMessage);
  except
  end;
end;

class procedure Assert.Fail<T>(const aLeft, aRight: T; aMessage: string);
var
  Tmp, Left, Right: TValue;
  Message: string;
begin
  Left  := TValue.From<T>(aLeft);
  Right := TValue.From<T>(aRight);
  if Left.TryCast(TypeInfo(string), Tmp) then
    Message := Format('Comparison error: expected <%s> but was <%s>',
                      [Left.AsString, Right.AsString])
  else
    Message := 'Comparison error';
  Message := (Message + sLineBreak + aMessage).Trim;
  Fail<T>(Message);
end;

end.

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

unit TestHSharp_Collections;

interface

uses
  TestFramework,
  System.Generics.Collections,
  HSharp.Collections,
  HSharp.Collections.Interfaces;

type
  TestCollections = class(TTestCase)
  published
    procedure WhenCreateAList_ShouldReturnAValidInstance;
    procedure WhenCreateADictionary_ShouldReturnAValidInstance;
    procedure WhenCreateAStack_ShouldReturnAValidInstance;
//    procedure AfterUse_ListShouldBeDestroyed;
//    procedure AfterUse_DictionaryShouldBeDestroyed;
  end;

implementation

uses
  System.Rtti,
  HSharp.Collections.List;

//procedure TestCollections.AfterUse_ListShouldBeDestroyed;
//var
//  List: IList<String>;
//  Vmi: TVirtualMethodInterceptor;
//  DestructorWasCalled: Boolean;
//
//  procedure CreateVirtualMethodInterceptor;
//  begin
//    Vmi := TVirtualMethodInterceptor.Create(TInterfacedList<string>);
//    Vmi.OnBefore :=
//      procedure(aInstance: TObject; aMethod: TRttiMethod;
//                const aArgs: TArray<TValue>; out aDoInvoke: Boolean;
//                out Result: TValue)
//      begin
//        if aMethod.Name = 'FreeInstance' then
//          DestructorWasCalled := True;
//      end;
//  end;
//
//  procedure SetupVirtualMethodInterceptor;
//  begin
//    Vmi.Proxify(List as TInterfacedList<string>);
//  end;
//
//  procedure ReleaseVirtualMethodInterceptor;
//  begin
//    Vmi.Free;
//  end;
//
//begin
//  CreateVirtualMethodInterceptor;
//  List := Collections.CreateList<string>;
//  SetupVirtualMethodInterceptor;
//  List.Add('123');
//  List.Add('abc');
//  List.Add('456');
//  List.Add('def');
//  List := nil;
//  ReleaseVirtualMethodInterceptor;
//  CheckTrue(DestructorWasCalled, 'FreeInstance of List was not called.');
//end;

procedure TestCollections.WhenCreateADictionary_ShouldReturnAValidInstance;
var
  Dict: IDictionary<string, Integer>;
begin
  Dict := Collections.CreateDictionary<string, Integer>;
  CheckTrue(Assigned(Dict), 'Correctly Dictionary was not created');
end;

procedure TestCollections.WhenCreateAList_ShouldReturnAValidInstance;
var
  List: IList<string>;
begin
  List := Collections.CreateList<string>;
  CheckTrue(Assigned(List), 'Correctly List was not created');
end;

procedure TestCollections.WhenCreateAStack_ShouldReturnAValidInstance;
var
  Stack: IStack<string>;
begin
  Stack := Collections.CreateStack<string>;
  CheckTrue(Assigned(Stack), 'Correctly Stack was not created');
end;

initialization
  RegisterTest(TestCollections.Suite);

end.


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

initialization
  RegisterTest(TestCollections.Suite);

end.


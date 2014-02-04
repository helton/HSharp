unit TestHSharp_ORM;

interface

uses
  TestFramework,
  Tests.Entities;

type
  TestMappingAttribute = class(TTestCase)
  published
    procedure Test_Mapping;
  end;

implementation

uses
  System.Rtti,
  System.SysUtils;

{ TestMappingAttributes }

procedure TestMappingAttribute.Test_Mapping;
begin
  {}
end;

initialization
  RegisterTest('HSharp.Mappings.Attributes', TestMappingAttribute.Suite);

end.


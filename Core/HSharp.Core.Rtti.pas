unit HSharp.Core.Rtti;

interface

uses
  System.Rtti;

var
  RttiContext: TRttiContext;

implementation

initialization
  RttiContext := TRttiContext.Create;

end.

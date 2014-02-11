unit HSharp.Container;

interface

uses
  HSharp.Container.Impl;

var
  GlobalContainer: TContainer;

implementation

initialization
  GlobalContainer := TContainer.Create;
finalization
  GlobalContainer.Free;

end.

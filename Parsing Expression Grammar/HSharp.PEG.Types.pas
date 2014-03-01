unit HSharp.PEG.Types;

interface

uses
  System.Rtti,
  HSharp.PEG.Node.Interfaces;

type
  TExpressionHandler = reference to function(const aNode: INode): TValue;

implementation

end.

      {******************************************************************}
      { SVG path classes                                                 }
      {                                                                  }
      { home page : http://www.mwcs.de                                   }
      { email     : martin.walter@mwcs.de                                }
      {                                                                  }
      { date      : 05-04-2008                                           }
      {                                                                  }
      { Use of this file is permitted for commercial and non-commercial  }
      { use, as long as the author is credited.                          }
      { This file (c) 2005, 2008 Martin Walter                           }
      {                                                                  }
      { This Software is distributed on an "AS IS" basis, WITHOUT        }
      { WARRANTY OF ANY KIND, either express or implied.                 }
      {                                                                  }
      { *****************************************************************}

unit SVGPath;

interface

uses
  Winapi.Windows, Winapi.GDIPOBJ,
  System.Types, System.Classes,
  SVGTypes, SVG;

type
  TSVGPathElement = class(TSVGObject)
  private
    FStartX: TFloat;
    FStartY: TFloat;
    FStopX: TFloat;
    FStopY: TFloat;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function New(Parent: TSVGObject): TSVGObject; override;
  public
    function GetBounds: TRectF; virtual; abstract;
    procedure AddToPath(Path: TGPGraphicsPath); virtual; abstract;
    procedure Read(SL: TStrings; var Position: Integer;
      Previous: TSVGPathElement); virtual;

    procedure PaintToGraphics(Graphics: TGPGraphics); override;
    procedure PaintToPath(Path: TGPGraphicsPath); override;

    property StartX: TFloat read FStartX write FStartX;
    property StartY: TFloat read FStartY write FStartY;
    property StopX: TFloat read FStopX write FStopX;
    property StopY: TFloat read FStopY write FStopY;
  end;

  TSVGPathMove = class(TSVGPathElement)
  private
  protected
    function New(Parent: TSVGObject): TSVGObject; override;
  public
    function GetBounds: TRectF; override;
    procedure AddToPath(Path: TGPGraphicsPath); override;
    procedure Read(SL: TStrings; var Position: Integer;
      Previous: TSVGPathElement); override;
  end;

  TSVGPathLine = class(TSVGPathElement)
  private
  protected
    function New(Parent: TSVGObject): TSVGObject; override;
  public
    function GetBounds: TRectF; override;
    procedure AddToPath(Path: TGPGraphicsPath); override;
    procedure Read(SL: TStrings; var Position: Integer;
      Previous: TSVGPathElement); override;
  end;

  TSVGPathCurve = class(TSVGPathElement)
  private
    FControl1X: TFloat;
    FControl1Y: TFloat;
    FControl2X: TFloat;
    FControl2Y: TFloat;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function New(Parent: TSVGObject): TSVGObject; override;
  public
    function GetBounds: TRectF; override;
    procedure AddToPath(Path: TGPGraphicsPath); override;
    procedure Read(SL: TStrings; var Position: Integer;
      Previous: TSVGPathElement); override;

    property Control1X: TFloat read FControl1X write FControl1X;
    property Control1Y: TFloat read FControl1Y write FControl1Y;
    property Control2X: TFloat read FControl2X write FControl2X;
    property Control2Y: TFloat read FControl2Y write FControl2Y;
  end;

  TSVGPathEllipticArc = class(TSVGPathElement)
  private
    FRX: TFloat;
    FRY: TFloat;
    FXRot: TFloat;
    FLarge: Integer;
    FSweep: Integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function New(Parent: TSVGObject): TSVGObject; override;
  public
    function GetBounds: TRectF; override;
    procedure AddToPath(Path: TGPGraphicsPath); override;
    procedure Read(SL: TStrings; var Position: Integer;
      Previous: TSVGPathElement); override;

    property RX: TFloat read FRX write FRX;
    property RY: TFloat read FRY write FRY;
    property XRot: TFloat read FXRot write FXRot;
    property Large: Integer read FLarge write FLarge;
    property Sweep: Integer read FSweep write FSweep;
  end;

  TSVGPathClose = class(TSVGPathElement)
  protected
    function New(Parent: TSVGObject): TSVGObject; override;
  public
    function GetBounds: TRectF; override;
    procedure AddToPath(Path: TGPGraphicsPath); override;
    procedure Read(SL: TStrings; var Position: Integer;
      Previous: TSVGPathElement); override;
  end;

implementation

uses
  System.SysUtils, System.Math,
  Winapi.GDIPAPI,
  SVGCommon, SVGParse;

// TSVGPathElement

procedure TSVGPathElement.AssignTo(Dest: TPersistent);
begin
  inherited;
  if Dest is TSVGPathElement then
  begin
    TSVGPathElement(Dest).FStartX := FStartX;
    TSVGPathElement(Dest).FStartY := FStartY;
    TSVGPathElement(Dest).FStopX :=  FStopX;
    TSVGPathElement(Dest).FStopY :=  FStopY;
  end;
end;

function TSVGPathElement.New(Parent: TSVGObject): TSVGObject;
begin
  Result := nil;
end;

procedure TSVGPathElement.Read(SL: TStrings; var Position: Integer;
  Previous: TSVGPathElement);
begin
  if Assigned(Previous) then
  begin
    FStartX := Previous.FStopX;
    FStartY := Previous.FStopY;
  end;
end;

procedure TSVGPathElement.PaintToGraphics(Graphics: TGPGraphics);
begin
end;

procedure TSVGPathElement.PaintToPath(Path: TGPGraphicsPath);
begin
end;

// TSVGPathMove

function TSVGPathMove.GetBounds: TRectF;
begin
  Result.Width := 0;
  Result.Height := 0;
end;

function TSVGPathMove.New(Parent: TSVGObject): TSVGObject;
begin
  Result := TSVGPathMove.Create(Parent);
end;

procedure TSVGPathMove.AddToPath(Path: TGPGraphicsPath);
begin
  Path.StartFigure;
end;

procedure TSVGPathMove.Read(SL: TStrings; var Position: Integer;
  Previous: TSVGPathElement);
begin
  inherited;
  if not TryStrToTFloat(SL[Position + 1], FStopX) then
    FStopX := 0;
  if not TryStrToTFloat(SL[Position + 2], FStopY) then
    FStopY := 0;

  if SL[Position] = 'm' then
  begin
    FStopX := FStartX + FStopX;
    FStopY := FStartY + FStopY;
  end;

  Inc(Position, 2);
end;


// TSVGPathLine

function TSVGPathLine.GetBounds: TRectF;
begin
  Result.Left := Min(FStartX, FStopX);
  Result.Top := Min(FStartY, FStopY);
  Result.Width := Abs(FStartX - FStopX);
  Result.Height := Abs(FStartY - FStopY);
end;

function TSVGPathLine.New(Parent: TSVGObject): TSVGObject;
begin
  Result := TSVGPathLine.Create(Parent);
end;

procedure TSVGPathLine.AddToPath(Path: TGPGraphicsPath);
begin
  Path.AddLine(FStartX, FStartY, FStopX, FStopY);
end;

procedure TSVGPathLine.Read(SL: TStrings; var Position: Integer;
  Previous: TSVGPathElement);
var
  Command: string;
begin
  inherited;

  Command := SL[Position];
  if (Command = 'L') or (Command = 'l') then
  begin
    if not TryStrToTFloat(SL[Position + 1], FStopX) then
      FStopX := 0;
    if not TryStrToTFloat(SL[Position + 2], FStopY) then
      FStopY := 0;

    if SL[Position] = 'l' then
    begin
      FStopX := FStartX + FStopX;
      FStopY := FStartY + FStopY;
    end;

    Inc(Position, 2);
  end;

  if (Command = 'H') or (Command = 'h') then
  begin
    if not TryStrToTFloat(SL[Position + 1], FStopX) then
      FStopX := 0;

    if Command = 'h' then
      FStopX := FStartX + FStopX;
    FStopY := FStartY;
    Inc(Position);
  end;


  if (Command = 'V') or (Command = 'v') then
  begin
    if not TryStrToTFloat(SL[Position + 1], FStopY) then
      FStopY := 0;

    if Command = 'v' then
      FStopY := FStartY + FStopY;
    FStopX := FStartX;
    Inc(Position);
  end;
end;


// TSVGPathCurve

procedure TSVGPathCurve.AssignTo(Dest: TPersistent);
begin
  inherited;
  if Dest is TSVGPathCurve then
  begin
    TSVGPathCurve(Dest).FControl1X := FControl1X;
    TSVGPathCurve(Dest).FControl1Y := FControl1Y;
    TSVGPathCurve(Dest).FControl2X := FControl2X;
    TSVGPathCurve(Dest).FControl2Y := FControl2Y;
  end;
end;

function TSVGPathCurve.GetBounds: TRectF;
var
  Right, Bottom: TFloat;
begin
  Result.Left := Min(FStartX, Min(FStopX, Min(FControl1X, FControl2X)));
  Result.Top := Min(FStartY, Min(FStopY, Min(FControl1Y, FControl2Y)));

  Right := Max(FStartX, Max(FStopX, Max(FControl1X, FControl2X)));
  Bottom := Max(FStartY, Max(FStopY, Max(FControl1Y, FControl2Y)));
  Result.Width := Right - Result.Left;
  Result.Height := Bottom - Result.Top;
end;

function TSVGPathCurve.New(Parent: TSVGObject): TSVGObject;
begin
  Result := TSVGPathCurve.Create(Parent);
end;

procedure TSVGPathCurve.AddToPath(Path: TGPGraphicsPath);
begin
  Path.AddBezier(FStartX, FStartY, FControl1X, FControl1Y,
    FControl2X, FControl2Y, FStopX, FStopY);
end;

procedure TSVGPathCurve.Read(SL: TStrings; var Position: Integer;
  Previous: TSVGPathElement);
var
  Command: string;
begin
  inherited;

  Command := SL[Position];
  if (Command = 'C') or (Command = 'c') then
  begin
    TryStrToTFloat(SL[Position + 1], FControl1X);
    TryStrToTFloat(SL[Position + 2], FControl1Y);
    TryStrToTFloat(SL[Position + 3], FControl2X);
    TryStrToTFloat(SL[Position + 4], FControl2Y);
    TryStrToTFloat(SL[Position + 5], FStopX);
    TryStrToTFloat(SL[Position + 6], FStopY);
    Inc(Position, 6);

    if Command = 'c' then
    begin
      FControl1X := FStartX + FControl1X;
      FControl1Y := FStartY + FControl1Y;
      FControl2X := FStartX + FControl2X;
      FControl2Y := FStartY + FControl2Y;
      FStopX := FStartX + FStopX;
      FStopY := FStartY + FStopY;
    end;
  end;

  if (Command = 'S') or (Command = 's') then
  begin
    FControl1X := FStartX;
    FControl1Y := FStartY;
    TryStrToTFloat(SL[Position + 1], FControl2X);
    TryStrToTFloat(SL[Position + 2], FControl2Y);
    TryStrToTFloat(SL[Position + 3], FStopX);
    TryStrToTFloat(SL[Position + 4], FStopY);
    Inc(Position, 4);

    if Previous is TSVGPathCurve then
    begin
      FControl1X := FStartX + (FStartX - TSVGPathCurve(Previous).FControl2X);
      FControl1Y := FStartY + (FStartY - TSVGPathCurve(Previous).FControl2Y);
    end;

    if Command = 's' then
    begin
      FControl2X := FStartX + FControl2X;
      FControl2Y := FStartY + FControl2Y;
      FStopX := FStartX + FStopX;
      FStopY := FStartY + FStopY;
    end;
  end;

  if (Command = 'Q') or (Command = 'q') then
  begin
    TryStrToTFloat(SL[Position + 1], FControl1X);
    TryStrToTFloat(SL[Position + 2], FControl1Y);
    TryStrToTFloat(SL[Position + 3], FStopX);
    TryStrToTFloat(SL[Position + 4], FStopY);
    FControl2X := FControl1X;
    FControl2Y := FControl1Y;
    Inc(Position, 4);

    if Command = 'q' then
    begin
      FControl1X := FStartX + FControl1X;
      FControl1Y := FStartY + FControl1Y;
      FControl2X := FStartX + FControl2X;
      FControl2Y := FStartY + FControl2Y;
      FStopX := FStartX + FStopX;
      FStopY := FStartY + FStopY;
    end;
  end;

  if (Command = 'T') or (Command = 't') then
  begin
    FControl1X := FStartX;
    FControl1Y := FStartY;
    TryStrToTFloat(SL[Position + 1], FStopX);
    TryStrToTFloat(SL[Position + 2], FStopY);
    Inc(Position, 2);

    if Previous is TSVGPathCurve then
    begin
      FControl1X := FStartX + (FStartX - TSVGPathCurve(Previous).FControl2X);
      FControl1Y := FStartY + (FStartY - TSVGPathCurve(Previous).FControl2Y);
    end;

    FControl2X := FControl1X;
    FControl2Y := FControl1Y;

    if Command = 't' then
    begin
      FStopX := FStartX + FStopX;
      FStopY := FStartY + FStopY;
    end;
  end;
end;


// TSVGPathEllipticArc

procedure TSVGPathEllipticArc.AssignTo(Dest: TPersistent);
begin
  inherited;
  if Dest is TSVGPathEllipticArc then
  begin
    TSVGPathEllipticArc(Dest).FRX := FRX;
    TSVGPathEllipticArc(Dest).FRY := FRY;
    TSVGPathEllipticArc(Dest).FXRot := FXRot;
    TSVGPathEllipticArc(Dest).FLarge := FLarge;
    TSVGPathEllipticArc(Dest).FSweep := FSweep;
  end;
end;

function TSVGPathEllipticArc.GetBounds: TRectF;
begin
  Result.Left := Min(FStartX, FStopX);
  Result.Top := Min(FStartY, FStopY);
  Result.Width := Abs(FStartX - FStopX);
  Result.Height := Abs(FStartY - FStopY);
end;

function TSVGPathEllipticArc.New(Parent: TSVGObject): TSVGObject;
begin
  Result := TSVGPathEllipticArc.Create(Parent);
end;

procedure TSVGPathEllipticArc.AddToPath(Path: TGPGraphicsPath);
var
  R: TGPRectF;
  X1, Y1: TFloat;
  DX2, DY2: TFloat;
  Angle: TFloat;
  SinAngle: TFloat;
  CosAngle: TFloat;
  LRX: TFloat;
  LRY: TFloat;
  PRX: TFloat;
  PRY: TFloat;
  PX1: TFloat;
  PY1: TFloat;
  RadiiCheck: TFloat;
  sign: TFloat;
  Sq: TFloat;
  Coef: TFloat;
  CX1: TFloat;
  CY1: TFloat;
  sx2: TFloat;
  sy2: TFloat;
  cx: TFloat;
  cy: TFloat;
  ux: TFloat;
  uy: TFloat;
  vx: TFloat;
  vy: TFloat;
  p: TFloat;
  n: TFloat;
  AngleStart: TFloat;
  AngleExtent: TFloat;
  ArcPath: TGPGraphicsPath;
  Matrix: TGPMatrix;
  Center: TGPPointF;
begin
  if (FStartX = FStopX) and (FStartY = FStopY) then
    Exit;

  if (FRX = 0) or (FRY = 0) then
  begin
    Path.AddLine(FStartX, FStartY, FStopX, FStopY);
    Exit;
  end;

  //
  // Elliptical arc implementation based on the SVG specification notes
  //

  // Compute the half distance between the current and the final point
  DX2 := (FStartX - FStopX) / 2.0;
  DY2 := (FStartY - FStopY) / 2.0;

  // Convert angle from degrees to radians
  Angle := DegToRad(FMod(FXRot, c360));
  cosAngle := cos(Angle);
  sinAngle := sin(Angle);

  //
  // Step 1 : Compute (x1, y1)
  //
  x1 := (cosAngle * DX2 + sinAngle * DY2);
  y1 := (-sinAngle * DX2 + cosAngle * DY2);
  // Ensure radii are large enough
  LRX := abs(Frx);
  LRY := abs(Fry);
  Prx := LRX * LRX;
  Pry := LRY * LRY;
  Px1 := x1 * x1;
  Py1 := y1 * y1;

  // check that radii are large enough
  RadiiCheck := Px1/Prx + Py1/Pry;
  if (RadiiCheck > 1) then
  begin
    LRX := sqrt(RadiiCheck) * LRX;
    LRY := sqrt(RadiiCheck) * LRY;
    Prx := LRX * LRX;
    Pry := LRY * LRY;
  end;

  //
  // Step 2 : Compute (cx1, cy1)
  //
  sign := IfThen(FLarge = FSweep, -1, 1);
  Sq := ((Prx * Pry)-(Prx * Py1)-(Pry * Px1)) / ((Prx * Py1)+(Pry * Px1));
  Sq := IfThen(Sq < 0, 0.0, Sq);
  Coef := (sign * sqrt(Sq));
  CX1 := Coef * ((LRX * y1) / LRY);
  CY1 := Coef * -((LRY * x1) / LRX);

  //
  // Step 3 : Compute (cx, cy) from (cx1, cy1)
  //
  sx2 := (FStartX + FStopX) / 2.0;
  sy2 := (FStartY + FStopY) / 2.0;
  cx := sx2 + (cosAngle * CX1 - sinAngle * CY1);
  cy := sy2 + (sinAngle * CX1 + cosAngle * CY1);

  //
  // Step 4 : Compute the angleStart (angle1) and the angleExtent (dangle)
  //
  ux := (x1 - CX1) / LRX;
  uy := (y1 - CY1) / LRY;
  vx := (-x1 - CX1) / LRX;
  vy := (-y1 - CY1) / LRY;

  // Compute the angle start
  n := (ux * ux) + (uy * uy);
  n := sqrt(n);
//  n := sqrt((ux * ux) + (uy * uy));
  p := ux; // (1 * ux) + (0 * uy)
  sign := IfThen(uy < 0, -1, 1);
  AngleStart := RadToDeg(sign * arccos(p / n));

  // Compute the angle extent
  n := sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
  p := ux * vx + uy * vy;
  sign := IfThen(ux * vy - uy * vx < 0, -1, 1);
  AngleExtent := RadToDeg(sign * arccos(p / n));
  if ((Fsweep = 0) and (AngleExtent > 0)) then
  begin
    AngleExtent := AngleExtent - c360;
  end else if ((FSweep = 1) and (AngleExtent < 0)) then
  begin
    AngleExtent := AngleExtent + c360;
  end;

  AngleStart := FMod(AngleStart, c360);
  AngleExtent := FMod(AngleExtent, c360);

  R.x := cx - LRX;
  R.y := cy - LRY;
  R.width := LRX * 2.0;
  R.height := LRY * 2.0;

  ArcPath := TGPGraphicsPath.Create;
  try
    ArcPath.AddArc(R, AngleStart, AngleExtent);
    Matrix := TGPMatrix.Create;
    try
      Center.X := cx;
      Center.Y := cy;
      Matrix.RotateAt(FXRot, Center);
      ArcPath.Transform(Matrix);
    finally
      Matrix.Free;
    end;
    Path.AddPath(ArcPath, True);
  finally
    ArcPath.Free;
  end;
end;

procedure TSVGPathEllipticArc.Read(SL: TStrings; var Position: Integer; Previous: TSVGPathElement);
var
  Command: string;
begin
  inherited;

  Command := SL[Position];
  if (Command = 'A') or (Command = 'a') then
  begin
    TryStrToTFloat(SL[Position + 1], FRX);
    TryStrToTFloat(SL[Position + 2], FRY);
    TryStrToTFloat(SL[Position + 3], FXRot);
    TryStrToInt(SL[Position + 4], FLarge);
    TryStrToInt(SL[Position + 5], FSweep);
    TryStrToTFloat(SL[Position + 6], FStopX);
    TryStrToTFloat(SL[Position + 7], FStopY);
    Inc(Position, 7);

    FRX := Abs(FRX);
    FRY := Abs(FRY);

    if FLarge <> 0 then
      FLarge := 1;

    if FSweep <> 0 then
      FSweep := 1;

    if Command = 'a' then
    begin
      FStopX := FStartX + FStopX;
      FStopY := FStartY + FStopY;
    end;
  end;
end;

// TSVGPathClose

function TSVGPathClose.GetBounds: TRectF;
begin
  Result.Width := 0;
  Result.Height := 0;
end;

function TSVGPathClose.New(Parent: TSVGObject): TSVGObject;
begin
  Result := TSVGPathClose.Create(Parent);
end;

procedure TSVGPathClose.Read(SL: TStrings; var Position: Integer;
  Previous: TSVGPathElement);
begin
  FStartX := Previous.FStopX;
  FStartY := Previous.FStopY;
  FStopX := FStartX;
  FStopY := FStartY;
end;

procedure TSVGPathClose.AddToPath(Path: TGPGraphicsPath);
begin
  Path.CloseFigure;
end;

end.

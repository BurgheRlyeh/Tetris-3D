unit Unit1;

interface

uses
  Winapi.Windows,Winapi.OpenGL,  System.SysUtils,  System.Classes,  Vcl.Graphics,  Vcl.Controls,  Vcl.Forms,  Vcl.Dialogs,
  Vcl.ExtCtrls,Vcl.Imaging.Jpeg,  GLScene,  GLObjects,  GLPersistentClasses,  GLCadencer,  GLWin32Viewer,
  GLDCE,  GLMaterial,  GLTexture,  GLHeightData,  GLTerrainRenderer,  GLVectorFileObjects,  GLBitmapFont,
  GLWindowsFont,  GLHUDObjects,  GLCrossPlatform,  GLCoordinates,  GLVectorGeometry,  GLFileMD2,  GLFile3DS, GLFileOBJ,
  GLContext,  GLEllipseCollision,  GLRenderContextInfo,  GLKeyboard,  GLProxyObjects,  GLState,  GLUtils,
  GLBaseClasses,  GLVectorTypes, GLWaterPlane, GLNavigator, GLAtmosphere, GLSkydome,
  GLGeomObjects, GLWindows, GLGui, Vcl.StdCtrls, GLGameMenu;

const
  imin=-1;
  imax=10;

  jmin=-1;
  jmax=20;

  kmin=-1;
  kmax=10;

  OSFigure=5;
  OSLevel=500;

type
  TForm1 = class(TForm)
    GLSceneViewer1: TGLSceneViewer;
    GLScene1: TGLScene;
    Timer1: TTimer;
    GLNavigator1: TGLNavigator;
    GLUserInterface1: TGLUserInterface;
    GLPoints1: TGLPoints;
    GLDummyCube0: TGLDummyCube;
    GLCamera1: TGLCamera;
    GLLightSource1: TGLLightSource;
    GLLightSource2: TGLLightSource;
    GLPlane0: TGLPlane;
    GLPlane1: TGLPlane;
    GLPlane2: TGLPlane;
    GLPlane3: TGLPlane;
    GLPlane4: TGLPlane;
    GLDummyCube1: TGLDummyCube;
    GLCube1: TGLCube;
    GLCube2: TGLCube;
    GLCube3: TGLCube;
    GLCube4: TGLCube;
    GLDummyCube2: TGLDummyCube;
    GLCube7: TGLCube;
    GLCube8: TGLCube;
    GLCube5: TGLCube;
    GLCube6: TGLCube;
    GLDummyCube3: TGLDummyCube;
    GLCube9: TGLCube;
    GLCube10: TGLCube;
    GLCube11: TGLCube;
    GLCube12: TGLCube;
    GLGameMenu1: TGLGameMenu;
    GLSceneViewer2: TGLSceneViewer;
    GLScene2: TGLScene;
    GLCamera2: TGLCamera;
    GLDummyCube4: TGLDummyCube;
    GLCube13: TGLCube;
    GLCube14: TGLCube;
    GLCube15: TGLCube;
    GLCube16: TGLCube;
    GLLightSource3: TGLLightSource;
    GLLightSource4: TGLLightSource;
    LabelMainMenu: TLabel;
    LabelNextStr: TLabel;
    LabelRecordStr: TLabel;
    LabelRecord: TLabel;
    LabelNewGame: TLabel;
    LabelTimeStr: TLabel;
    LabelTime: TLabel;
    LabelScoreStr: TLabel;
    LabelScore: TLabel;
    Timer2: TTimer;
    Timer3: TTimer;
    Image1: TImage;
    LabelPlay: TLabel;
    LabelHelp: TLabel;
    LabelExit: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure GLSceneViewer1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GLSceneViewer1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure LabelMainMenuClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure LabelExitClick(Sender: TObject);
    procedure LabelPlayClick(Sender: TObject);
    procedure LabelNewGameClick(Sender: TObject);
    procedure LabelHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  Comp1, Comp2: TComponent;

  mx, my: Single;
  Xorigin, Yorigin, Zorigin: single;

  Time, Score, SRecord, SFigure, SLevel: Integer;
  i, j, k, n, min, sec: ShortInt;

  FigureExists, GhostOn, Start, Help, Defeat: Boolean;

  Cube: array [imin..imax, jmin..jmax, kmin..kmax] of TGLCube;

  T: array [imin..imax, jmin..jmax, kmin..kmax] of Boolean; 

implementation

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GLSceneViewer1.Free; // turn off viewers
  GLSceneViewer2.Free;
end;

procedure FieldUpdate(); // show/hide cubes
begin
  for i:=imin+1 to imax-1 do
    for j:=jmin+1 to jmax do
      for k:=kmin+1 to kmax-1 do
        Case T[i,j,k] of
          False:
            Cube[i,j,k].Visible:=False;
          True:
            Cube[i,j,k].Visible:=True;
        End;
end;

function MoveCheck(i1,i2: integer; // nums of cubes fun have to check
                   sx,sy,sz: shortint // steps
                                     ):boolean;
begin
  MoveCheck:=True;

  for i:=i1 to i2 do
    begin
      Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));

      if (T[Round(TGLCube(Comp1).AbsolutePosition.X-0.5)+sx,
            Round(TGLCube(Comp1).AbsolutePosition.Y-0.5)+sy,
            Round(TGLCube(Comp1).AbsolutePosition.Z-0.5)+sz]=True)
      then
        MoveCheck:=False;
    end;
end;

procedure PDUpdate(object1, object2: string);
begin
  Comp1:=Form1.FindComponent(object1);
  Comp2:=Form1.FindComponent(object2);

  if (object1[3]='D')
  then
    with TGLDummyCube(Comp1)
    do
      begin
        Position:=TGLDummyCube(Comp2).Position;
        Direction:=TGLDummyCube(Comp2).Direction;
        Up:=TGLDummyCube(Comp2).Up;
      end
  else
    with TGLCube(Comp1)
    do
      begin
        Position:=TGLCube(Comp2).Position;
        Direction:=TGLCube(Comp2).Direction;
        Up:=TGLCube(Comp2).Up;
      end;
end;

procedure fall();
begin
  if (MoveCheck(1,4,0,-1,0))
  then
    Form1.GLDummyCube1.Position.Y:=Form1.GLDummyCube1.Position.Y-1
  else
    for i:=1 to 4 do
      begin
        Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));

        T[Round(TGLCube(Comp1).AbsolutePosition.X-0.5),
          Round(TGLCube(Comp1).AbsolutePosition.Y-0.5),
          Round(TGLCube(Comp1).AbsolutePosition.Z-0.5)]:=True;

        with Cube[Round(TGLCube(Comp1).AbsolutePosition.X-0.5),
                  Round(TGLCube(Comp1).AbsolutePosition.Y-0.5),
                  Round(TGLCube(Comp1).AbsolutePosition.Z-0.5)]
        do
          begin
            Material.Texture:=TGLCube(Comp1).Material.Texture;
            Direction:=TGLCube(Comp1).Direction;
            Up:=TGLCube(Comp1).Up;
          end;

        Score:=Score+SFigure;

        FigureExists:=False;
        Form1.Timer1.Interval:=1;
      end;

  PDUpdate('GLDummyCube2','GLDummyCube1');

  for i:=5 to 8 do
    begin
      PDUpdate('GLCube'+IntToStr(i),'GLCube'+IntToStr(i-4));
    end;
end;

procedure ghost();
begin
  for i:=9 to 12 do
    begin
      Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));
      TGLCube(Comp1).Visible:=GhostOn;
    end;

  PDUpdate('GLDummyCube3','GLDummyCube1');

  while MoveCheck(9,12,0,-1,0)
  do
  Form1.GLDummyCube3.Position.Y:=Form1.GLDummyCube3.Position.Y-1;
end;

procedure cleaner();
var
  c: ShortInt; // number of cubes on level
begin
  for j:=jmin+1 to jmax-1 do
    begin
      c:=0;

      for i:=imin+1 to imax-1 do
        for k:=kmin+1 to kmax-1 do
          if (T[i,j,k]=True)
          then
            c:=c+1;

      if (c=100)
      then
        begin
          Score:=Score+SLevel;

          for c:=j to jmax-2 do
            for i:=imin+1 to imax-1 do
              for k:=kmin+1 to kmax-1 do
                begin
                  T[i,c,k]:=T[i,c+1,k];

                  with Cube[i,c,k] do
                    begin
                      Visible:=Cube[i,c+1,k].Visible;
                      Material.Texture:=Cube[i,c+1,k].Material.Texture;

                      Direction:=Cube[i,c+1,k].Direction;
                      Up:=Cube[i,c+1,k].Up;
                    end;
                end;
        end;
    end;
end;

procedure LoadRecord();
var
  f: textfile;
  ch: char;
  str: string;
begin
  if FileExists('Other\Record.txt')
  then
    begin
      Assign(f, 'Other\Record.txt');
      Reset(f);

      while (not Eof(f))
      do
        begin
          read(f, ch);
          str:=str+ch;
        end;

      CloseFile(f);

      SRecord:=StrToInt(str);
      Form1.LabelRecord.Caption:=str;
    end;
end;

procedure RewriteRecord();
var
  f: textfile;
  str: string;
begin
  if FileExists('Other\Record.txt')
  then
    begin
      Assign(f, 'Other\Record.txt');
      Rewrite(f);

      write(f, IntToStr(SRecord));

      CloseFile(f);
    end;
end;

procedure FigureCreate();
var
  f: textfile;
  ch: char;
  str: string;
begin
  Form1.GLDummyCube1.Position.X:=Xorigin;
  Form1.GLDummyCube1.Position.Y:=Yorigin;
  Form1.GLDummyCube1.Position.Z:=Zorigin;

  Form1.GLDummyCube1.Direction.SetVector(0,0,1);
  Form1.GLDummyCube1.Up.SetVector(0,1,0);

  Form1.Timer1.Interval:=Time;

  SFigure:=OSFigure;
  SLevel:=OSLevel;

  for i:=1 to 4 do
    begin
      Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));
      Comp2:=Form1.FindComponent('GLCube'+IntToStr(i+12));

      PDUpdate('GLCube'+IntToStr(i), 'GLCube'+IntToStr(i+12));

      TGLCube(Comp1).Material:=TGLCube(Comp2).Material;
    end;

  randomize;
  n:=random(10);

  if FileExists('Media\'+IntToStr(n)+'.bmp')
  then
    for i:=13 to 16 do
      begin
        Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));

        TGLCube(Comp1).Material.Texture.Image.LoadFromFile('Media\'+IntToStr(n)+'.bmp');
      end;

  if FileExists('Coordinates\'+IntToStr(n)+'.txt')
  then
    begin
      Assign(f, 'Coordinates\'+IntToStr(n)+'.txt');
      Reset(f);

      while (not Eof(f)) do
        for i:=13 to 16 do
          begin
            str:='';
            n:=0;

            while (not Eoln(f)) do
              begin
                Read(f, ch);

                if (ch<>' ')
                then
                  str:=str+ch
                else
                  begin
                    Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));

                    case n of
                      0:
                        TGLCube(Comp1).Position.X:=StrToFloat(str);
                      1:
                        TGLCube(Comp1).Position.Y:=StrToFloat(str);
                      2:
                        TGLCube(Comp1).Position.Z:=StrToFloat(str);
                    end;

                    str:='';
                    n:=n+1;
                  end;
              end;

            Readln(f, ch);
          end;

      CloseFile(f);
    end;

  //defeat check
  for i:=1 to 4 do
    begin
      Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));

      if (T[Round(TGLCube(Comp1).AbsolutePosition.X-0.5),
            Round(TGLCube(Comp1).AbsolutePosition.Y-0.5)-1,
            Round(TGLCube(Comp1).AbsolutePosition.Z-0.5)]=True)
      and (Defeat=False)
        then
          begin
            Form1.Timer1.Interval:=0;

            Application.Title:='Tetris 3D';
            ShowMessage('Game Over'+#13#10+'Your Score: '+IntToStr(Score));

            Defeat:=True;
          end;
    end;

  for i:=9 to 12 do
    begin
      PDUpdate('GLCube'+IntToStr(i),'GLCube'+IntToStr(i-8));

      Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));
      Comp2:=Form1.FindComponent('GLCube'+IntToStr(i-8));

      TGLCube(Comp1).Material:=TGLCube(Comp2).Material;
      TGLCube(Comp1).Material.Texture.ImageAlpha:=tiaInverseLuminanceSqrt;
    end;
  ghost();

  PDUpdate('GLDummyCube2','GLDummyCube1');

  for i:=5 to 8 do
    begin
      PDUpdate('GLCube'+IntToStr(i),'GLCube'+IntToStr(i-4));
    end;

  FigureExists:=True;
end;

procedure newgame();
begin
  Defeat:=False;

  Time:=1000;
  Form1.Timer1.Interval:=0;
  Form1.Timer3.Interval:=500;

  mx := 1;
  my := 1;

  LoadRecord();

  for i:=imin to imax do
    for j:=jmin to jmax do
      for k:=kmin to kmax do
        if   (i=imin) or (i=imax)
          or (j=jmin)
          or (k=kmin) or (k=kmax)
        then
          T[i,j,k]:=True
        else
          T[i,j,k]:=False;

  for i:=imin+1 to imax-1 do
    for j:=jmin+1 to jmax do
      for k:=kmin+1 to kmax-1 do
        T[i,j,k]:=False;

  for i:=imin+1 to imax-1 do
    for j:=jmin+1 to jmax do
      for k:=kmin+1 to kmax-1 do
        begin
          Cube[i,j,k].Visible:=False;

          Cube[i,j,k].Material.Texture.Disabled:=False;

          Cube[i,j,k].Direction.SetVector(1,0,0);
          Cube[i,j,k].Up.SetVector(0,1,0);

          Cube[i,j,k].Position.X:=i+0.5;
          Cube[i,j,k].Position.Y:=j+0.5;
          Cube[i,j,k].Position.Z:=k+0.5;
        end;

  FieldUpdate();

  n:=random(10);
  FigureCreate();
  n:=random(10);

  // floor
  Form1.GLPlane0.Material.Texture.Image.LoadFromFile('Media\1x1.bmp');
  Form1.GLPlane0.Material.Texture.Disabled:=False;

  // walls
  for i:=1 to 4 do
    begin
      Comp1:=Form1.FindComponent('GLPlane'+IntToStr(i));

      TGLPlane(Comp1).Material.Texture.Image.LoadFromFile('Media\2x1.bmp');
      TGLPlane(Comp1).Material.Texture.Disabled:=False;
    end;

  // Cubes
  for i:=1 to 16 do
    begin
      Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));

      TGLCube(Comp1).Material.Texture.Disabled:=False;
    end;

  Score:=0;
  LoadRecord();

  min:=0;
  sec:=0;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Xorigin:=Form1.GLDummyCube1.Position.X;
  Yorigin:=Form1.GLDummyCube1.Position.Y;
  Zorigin:=Form1.GLDummyCube1.Position.Z;

  for i:=imin+1 to imax-1 do
    for j:=jmin+1 to jmax do
      for k:=kmin+1 to kmax-1 do
        begin
          Cube[i,j,k]:=TGLCube.Create(Form1);
          Cube[i,j,k].Parent:=Form1.GLDummyCube0;
        end;

  n:=random(10);
  FigureCreate();

  Form1.Timer1.Interval:=0;
  Form1.Timer3.Interval:=0;
  FigureExists:=True;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  procedure ChangeAbsPos(i1,i2,d: ShortInt);
  begin
    for i:=i1 to i2 do
      begin
        Comp1:=Form1.FindComponent('GLCube'+IntToStr(i));
        Comp2:=Form1.FindComponent('GLCube'+IntToStr(i+d));

        TGLCube(Comp1).AbsolutePosition:=TGLCube(Comp2).AbsolutePosition;
      end;
  end;

begin
  case Key of
    // ESC
    VK_ESCAPE:
      begin
        if (Form1.Timer1.Interval>0)
        then
          Form1.Timer1.Interval:=0
        else
          begin
            mx:=Mouse.CursorPos.X;
            my:=Mouse.CursorPos.Y;
            Form1.Timer1.Interval:=Time;
          end;
      end;
    // SPACE
    VK_SPACE:
      if (Form1.Timer1.Interval<>0)
      then
        begin
          Form1.Timer1.Interval:=1;
        end;
    // CTRL
    VK_CONTROL:
      begin
        GhostOn:=not GhostOn;
      end;
    // R
    ord('R'):
      begin
        GLPoints1.Position.Y:=10;
      end;
    // F
    ord('F'):
      begin
        GLPoints1.Position.Y:=5;
      end;
    // C
    ord('C'):
      begin
        GLPoints1.Position.Y:=0;
      end;
  end;

  if (Form1.Timer1.Interval<>0)
  then
    if (ssShift in Shift)
    then
      case Key of
        // W
        ord('W'):
          if (MoveCheck(1,4,0,0,-1))
          then
            Form1.GLDummyCube1.Position.Z:=Form1.GLDummyCube1.Position.Z-1;
        // S
        ord('S'):
          if (MoveCheck(1,4,0,0,1))
          then
            Form1.GLDummyCube1.Position.Z:=Form1.GLDummyCube1.Position.Z+1;
        // A
        ord('A'):
          if (MoveCheck(1,4,-1,0,0))
          then
            Form1.GLDummyCube1.Position.X:=Form1.GLDummyCube1.Position.X-1;
        // D
        ord('D'):
          if (MoveCheck(1,4,1,0,0))
          then
            Form1.GLDummyCube1.Position.X:=Form1.GLDummyCube1.Position.X+1;
      end
    else
      case Key of
        // Q
        ord('Q'):
          begin
            Form1.GLDummyCube2.RollAngle:=Form1.GLDummyCube2.RollAngle+90;

            if (MoveCheck(5,8,0,0,0))
            then
              begin
                ChangeAbsPos(1,4,4);

                PDUpdate('GLDummyCube3','GLDummyCube1');
                ChangeAbsPos(9,12,-8);
              end;

            Form1.GLDummyCube2.RollAngle:=Form1.GLDummyCube2.RollAngle-90;
          end;
        // E
        ord('E'):
          begin
            Form1.GLDummyCube2.RollAngle:=Form1.GLDummyCube2.RollAngle-90;

            if (MoveCheck(5,8,0,0,0))
            then
              begin
                ChangeAbsPos(1,4,4);

                PDUpdate('GLDummyCube3','GLDummyCube1');
                ChangeAbsPos(9,12,-8);
              end;

            Form1.GLDummyCube2.RollAngle:=Form1.GLDummyCube2.RollAngle+90
          end;
        // W
        ord('W'):
          begin
            Form1.GLDummyCube2.PitchAngle:=Form1.GLDummyCube2.PitchAngle+90;

            if (MoveCheck(5,8,0,0,0))
            then
              begin
                ChangeAbsPos(1,4,4);

                PDUpdate('GLDummyCube3','GLDummyCube1');
                ChangeAbsPos(9,12,-8);
              end;

            if (i=3) then
            Form1.GLDummyCube2.PitchAngle:=Form1.GLDummyCube2.PitchAngle-90
          end;
        // S
        ord('S'):
          begin
            Form1.GLDummyCube2.PitchAngle:=Form1.GLDummyCube2.PitchAngle-90;

            if (MoveCheck(5,8,0,0,0))
            then
              begin
                ChangeAbsPos(1,4,4);

                PDUpdate('GLDummyCube3','GLDummyCube1');
                ChangeAbsPos(9,12,-8);
              end;

            Form1.GLDummyCube2.PitchAngle:=Form1.GLDummyCube2.PitchAngle+90
          end;
        // A
        ord('A'):
          begin
            Form1.GLDummyCube2.TurnAngle:=Form1.GLDummyCube2.TurnAngle+90;

            if (MoveCheck(5,8,0,0,0))
            then
              begin
                ChangeAbsPos(1,4,4);

                PDUpdate('GLDummyCube3','GLDummyCube1');
                ChangeAbsPos(9,12,-8);
              end;

            Form1.GLDummyCube2.TurnAngle:=Form1.GLDummyCube2.TurnAngle-90
          end;
        // D
        ord('D'):
          begin
            Form1.GLDummyCube2.TurnAngle:=Form1.GLDummyCube2.TurnAngle-90;

            if (MoveCheck(5,8,0,0,0))
            then
              begin
                ChangeAbsPos(1,4,4);

                PDUpdate('GLDummyCube3','GLDummyCube1');
                ChangeAbsPos(9,12,-8);
              end;

            Form1.GLDummyCube2.TurnAngle:=Form1.GLDummyCube2.TurnAngle+90
          end;
      end;

  PDUpdate('GLDummyCube2','GLDummyCube1');

  for i:=5 to 8 do
    begin
      PDUpdate('GLCube'+IntToStr(i),'GLCube'+IntToStr(i-4));
    end;

  ghost();
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  dScore: Integer;
begin
  FieldUpdate();
  Cleaner();

  if (FigureExists)
  then
    fall()
  else
    FigureCreate();

  LabelScore.Caption:=IntToStr(Score);

  if (Score>SRecord)
  then
    begin
      SRecord:=Score;
      RewriteRecord();
      LabelRecord.Caption:=IntToStr(SRecord);
    end;

  dScore:=Score;

  SFigure:=OSFigure;
  SLevel:=OSLevel;

  if (dScore>2000)
  then
    repeat
      Timer1.Interval:=Round(Timer1.Interval*0.9);
      dScore:=dScore-2000;

      SFigure:=SFigure+5;
      SLevel:=SLevel+5;
    until dScore<1000;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
  minstr, secstr: string;
begin
  if (sec+1=60)
  then
    begin
      min:=min+1;
      sec:=0;
    end
  else
    sec:=sec+1;

  if (min<10)
  then
    minstr:='0'+IntToStr(min)
  else
    minstr:=IntToStr(min);

  if (sec<10)
  then
    secstr:=':0'+IntToStr(sec)
  else
    secstr:=':'+IntToStr(sec);

  LabelTime.Caption:=minstr+secstr;
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
  if (Timer1.Interval=0)
  then
    Timer2.Interval:=0
  else
    begin
      Timer2.Interval:=1000;
    end;

  //LabelTime.Visible:=not LabelTime.Visible;

  if (Timer2.Interval=0)
    and (Timer1.Interval=0)
    and (Image1.Visible=False)
  then
    LabelTime.Visible:=not LabelTime.Visible
  else
    if (min<>0) or (sec<>0)
    then
      LabelTime.Visible:=True;
end;

procedure TForm1.GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Form1.Timer1.Interval<>0)
  then
    begin
      GLCamera1.MoveAroundTarget((my-y), (0));
      mx := x;
      my := y;
    end;
end;

procedure TForm1.GLSceneViewer1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  // Z
  if (GLCamera1.Position.Z>0)
  then
    GLCamera1.Position.Z:=GLCamera1.Position.Z-10E-2
  else
    GLCamera1.Position.Z:=GLCamera1.Position.Z+10E-2;
end;

procedure TForm1.GLSceneViewer1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  // Z
  if (GLCamera1.Position.Z<0)
  then
    GLCamera1.Position.Z:=GLCamera1.Position.Z-10E-2
  else
    GLCamera1.Position.Z:=GLCamera1.Position.Z+10E-2;
end;

procedure TForm1.LabelExitClick(Sender: TObject);
begin
  if (Help)
  then
    begin
      LabelPlay.Visible:=True;
      LabelHelp.Visible:=True;
      LabelExit.Caption:='Exit';

      Image1.Picture.LoadFromFile('Media\tetris.bmp');

      Help:=False;
    end
  else
    Form1.Close;
end;

procedure TForm1.LabelHelpClick(Sender: TObject);
begin
  LabelPlay.Visible:=False;
  LabelHelp.Visible:=False;
  LabelExit.Caption:='Close';

  Image1.Picture.LoadFromFile('Media\help.bmp');

  Help:=True;
end;

procedure TForm1.LabelMainMenuClick(Sender: TObject);
begin
  // Unvisible
  GLSceneViewer1.Visible:=False;
  GLSceneViewer2.Visible:=False;
  LabelMainMenu.Visible:=False;
  LabelNextStr.Visible:=False;
  LabelRecordStr.Visible:=False;
  LabelRecord.Visible:=False;
  LabelNewGame.Visible:=False;
  LabelTimeStr.Visible:=False;
  LabelTime.Visible:=False;
  LabelScoreStr.Visible:=False;
  LabelScore.Visible:=False;

  // Visible
  Image1.Visible:=True;
  LabelPlay.Visible:=True;
  LabelHelp.Visible:=True;
  LabelExit.Visible:=True;

  Timer1.Interval:=0;
  Timer3.Interval:=0;
end;

procedure TForm1.LabelNewGameClick(Sender: TObject);
begin
  Timer3.Interval:=500;
  newgame();
end;

procedure TForm1.LabelPlayClick(Sender: TObject);
begin
  // Unvisible
  Image1.Visible:=False;
  LabelPlay.Visible:=False;
  LabelHelp.Visible:=False;
  LabelExit.Visible:=False;

  sleep(100);

  newgame();

  // Visible
  GLSceneViewer1.Visible:=True;
  GLSceneViewer2.Visible:=True;
  LabelMainMenu.Visible:=True;
  LabelNextStr.Visible:=True;
  LabelRecordStr.Visible:=True;
  LabelRecord.Visible:=True;
  LabelNewGame.Visible:=True;
  LabelTimeStr.Visible:=True;
  LabelTime.Visible:=True;
  LabelScoreStr.Visible:=True;
  LabelScore.Visible:=True;
end;

end.

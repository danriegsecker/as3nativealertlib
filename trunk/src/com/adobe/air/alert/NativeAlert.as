package com.adobe.air.alert
{
    import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;

	[Event(name=AlertEvent.ALERT_CLOSED_EVENT, type="com.adobe.air.alert.AlertEvent")]

	public class NativeAlert
		extends NativeWindow
	{
	    public static const YES:uint = 0x0001;
	    public static const NO:uint = 0x0002;
	    public static const OK:uint = 0x0004;
	    public static const CANCEL:uint= 0x0008;

        public function NativeAlert()
        {
            super(this.getWinOptions());
			this.createBackGround()
            this.visible = false;
			this.alwaysInFront = true;
	    }

		protected function getWinOptions(): NativeWindowInitOptions
		{
            var result:NativeWindowInitOptions = new NativeWindowInitOptions();
            result.appearsInWindowMenu = false;
            result.hasMenu = false;
            result.maximizable = false;
            result.minimizable = false;
            result.resizable = false;
            result.transparent = true;
            result.systemChrome = NativeWindowSystemChrome.NONE;
            result.type = NativeWindowType.LIGHTWEIGHT;
			return result;
		}

		private var sprite: Sprite;
	    protected function createBackGround(): void
	    {
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();

			this.bounds = new Rectangle(100, 100, 800, 600);
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.sprite = new Sprite();
			this.sprite.alpha = 1;
	    	this.sprite.contextMenu = cm;
			this.stage.addChild(this.sprite);
			this.sprite.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
	    }

	    private function onMouseDown(e:MouseEvent): void
	    {
	    	this.startMove();
	    }

		private function drawBackGround(): void
		{
			this.sprite.graphics.clear();
            this.sprite.graphics.beginFill(0x333333);
            this.sprite.graphics.drawRoundRect(0, 0, this.width, this.height, 10, 10);
            this.sprite.graphics.endFill();
		}

		public override function set height(newHeight: Number): void
		{
			super.height = newHeight;
			this.drawBackGround();
		}

		public override function set width(newWidth: Number): void
		{
			super.width = newWidth;
			this.drawBackGround();
		}
		private var text: String;
		private var alertTitle: String;

		private var textField: TextField;
		private var titleText: TextField;

	    private function createTexts(): void
	    {
			if (!this.titleText)
			{
	            this.titleText = new TextField();
	            this.titleText.autoSize = TextFieldAutoSize.LEFT;
	            var titleFormat:TextFormat = this.titleText.defaultTextFormat;
	            titleFormat.font = "Verdana";
	            titleFormat.bold = true;
	            titleFormat.color = 0xFFFFFF;
	            titleFormat.size = 12;
				titleFormat.align = TextFormatAlign.LEFT;
	            this.titleText.defaultTextFormat = titleFormat;
	            this.titleText.multiline = false;
	            this.titleText.selectable = false;
	            this.titleText.wordWrap = false;
	            this.titleText.text = this.alertTitle;
	            this.sprite.addChild(this.titleText);
			}

	        if (!this.textField)
	        {
				this.textField = new TextField();
				this.textField.autoSize = TextFieldAutoSize.LEFT;
		        var textFormat: TextFormat = this.textField.defaultTextFormat;
		        textFormat.font = "Verdana";
		        textFormat.bold = false;
		        textFormat.color = 0xFFFFFF;
		        textFormat.size = 10;
				textFormat.align = TextFormatAlign.LEFT;
		        this.textField.defaultTextFormat = textFormat;
				this.textField.text = this.text;
				this.textField.multiline = true;
				this.textField.wordWrap = true;
				this.textField.text = this.text;
				this.textField.width = 200;
                this.sprite.addChild(this.textField);
	        }
	    }

	    private var buttonFlags:uint = OK;
		private var buttons:Array = [];

		private function createButton(label: String, name: String): CustomSimpleButton
		{
			var button: CustomSimpleButton = new CustomSimpleButton(label);
			button.name = name;
			button.addEventListener(MouseEvent.CLICK, clickHandler);
			this.sprite.addChild(button);
			this.buttons.push(button);
			return button;
		}

		private var closeHandler: Function =  null;
		private function removeAlert(buttonPressed:String):void
		{	
			this.visible = false;
	
			var closeEvent: AlertEvent = new AlertEvent();
			if (buttonPressed == "YES")
				closeEvent.detail = NativeAlert.YES;
			else if (buttonPressed == "NO")
				closeEvent.detail = NativeAlert.NO;
			else if (buttonPressed == "OK")
				closeEvent.detail = NativeAlert.OK;
			else if (buttonPressed == "CANCEL")
				closeEvent.detail = NativeAlert.CANCEL;
			this.dispatchEvent(closeEvent);
			
			this.close();
		}

		private function clickHandler(event: MouseEvent): void
		{
			var name:String = CustomSimpleButton(event.currentTarget).name;
			removeAlert(name);
		}

		private const btn_space: uint = 10;

		private var msgIcon: Bitmap;
		private function createChildren():void
		{	
			// Create the icon object, if any.
			if (this.msgIcon != null)
			{
				this.sprite.addChild(this.msgIcon);
			}
				
			// Create the UITextField to display the message.
			this.createTexts();

			var button: CustomSimpleButton;
	
			if (this.buttonFlags & NativeAlert.OK)
			{
				button = this.createButton("OK", "OK");
			}
	
			if (this.buttonFlags & NativeAlert.YES)
			{
				button = this.createButton("YES", "YES");
			}
	
			if (this.buttonFlags & NativeAlert.NO)
			{
				button = this.createButton("NO", "NO");
			}
	
			if (this.buttonFlags & NativeAlert.CANCEL)
			{
				button = this.createButton("CANCEL", "CANCEL");
			}

			this.height = this.titleText.height + Math.max(this.textField.height, this.msgIcon != null ? 50 : 0) + 5 + (this.btn_space * 3) + button.height;
			this.width = Math.max(this.titleText.width, (this.textField.width + (this.msgIcon != null ? 50 : 0)));
			this.width = Math.max(this.width, (this.buttons.length * button.width) + ((this.buttons.length - 1) * this.btn_space));
			this.width = this.width + (this.btn_space * 2);
			
			this.titleText.x = (this.width / 2) - (this.titleText.width / 2);
			this.titleText.y = 5;

			if (this.msgIcon != null)
			{
				var posX: int = 2;
				var posY: int = 2;
				var scaleX: Number = 1;
				var scaleY: Number = 1;
	            var bitmapData:BitmapData = this.msgIcon.bitmapData;
	            if (bitmapData.width > 50 || bitmapData.height > Math.max(this.textField.height, 50))
	            {
	            	var __x: int = bitmapData.width - 50;
	            	var __y: int = bitmapData.height - Math.max(this.textField.height, 50);
            		scaleX = (__x > __y) ? 50 / bitmapData.width : Math.max(this.textField.height, 50) / bitmapData.height;
	            	scaleY = scaleX;
	            	posX = 27 - ((bitmapData.width * scaleX) / 2);
	            	posY = 5 + this.titleText.height + this.btn_space + ((Math.max(this.textField.height, 50) / 2) + 2) - ((bitmapData.height * scaleY) / 2);
	            }
	            else
	            {
		            posX = 27 - (bitmapData.width / 2);
		            posY = 5 + this.titleText.height + this.btn_space + ((Math.max(this.textField.height, 50) / 2) + 2) - (bitmapData.height / 2);					
	            }
	            this.msgIcon.scaleX = scaleX;
	            this.msgIcon.scaleY = scaleY;
	            this.msgIcon.x = posX;
	            this.msgIcon.y = posY;
			}
			this.textField.x = (this.msgIcon != null ? 50 : 0) + (((this.width - (this.msgIcon != null ? 50 : 0)) / 2) - (this.textField.width / 2));
			
			this.textField.y = 5 + this.titleText.height + this.btn_space;

			var btnTop: uint = this.height - (button.height + this.btn_space);
			var btnLeft: uint = (this.width / 2) - (((button.width * this.buttons.length) + (this.btn_space * (this.buttons.length - 1))) / 2);
			for (var x: int = 0; x < this.buttons.length; x++)
			{
				(this.buttons[x] as CustomSimpleButton).y = btnTop;
				(this.buttons[x] as CustomSimpleButton).x = btnLeft;
				btnLeft = btnLeft + button.width + this.btn_space;
			}
		}

	    public static function show(text:String = "",
	    							title:String = "",
	                                flags:uint = 0x4 /* Alert.OK */,
	                                closeHandler:Function = null,
	                                icon: Bitmap = null): NativeAlert
	    {

//	        var modal:Boolean = (flags & Alert.NONMODAL) ? false : true;

	        var alert:NativeAlert = new NativeAlert();

	        if (flags & NativeAlert.OK ||
	            flags & NativeAlert.CANCEL ||
	            flags & NativeAlert.YES ||
	            flags & NativeAlert.NO)
	        {
	            alert.buttonFlags = flags;
	        }

	        alert.closeHandler = closeHandler;
	        alert.text = text;
	        alert.alertTitle = title;

	        if (icon != null)
	        {
				alert.msgIcon = new Bitmap(icon.bitmapData);
		    	alert.msgIcon.smoothing = true;
	        }
	        
	        alert.createChildren();
			alert.visible = true;

	        if (closeHandler != null)
	        {
	            alert.addEventListener(AlertEvent.ALERT_CLOSED_EVENT, closeHandler);
	        }

	        return alert;
	    }
	}
}

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.SimpleButton;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class CustomSimpleButton 
	extends SimpleButton
{
    private var upColor:uint   = 0xFFCC00;
    private var overColor:uint = 0xCCFF00;
    private var downColor:uint = 0x00CCFF;

    public function CustomSimpleButton(label: String)
    {
    	super();
        this.downState      = new ButtonDisplayState(downColor, 20, 60, label);
        this.overState      = new ButtonDisplayState(overColor, 20, 60, label);
        this.upState        = new ButtonDisplayState(upColor, 20, 60, label);
        this.hitTestState   = new ButtonDisplayState(overColor, 40, 120, label);
//        this.hitTestState.x = 0;  // -(this.height / 4);
//        this.hitTestState.y = 0; // this.hitTestState.x;
        this.useHandCursor  = true;
    }
}

class ButtonDisplayState 
	extends Sprite
{
    private var bgColor:uint;
	private var _height: uint;
	private var _width: uint;
    public function ButtonDisplayState(bgColor: uint, height: uint, width: uint, caption: String)
    {
    	super();
        this.bgColor = bgColor;
        this._height  = height;
        this._width   = width;
        var label: TextField = new TextField();
		label.autoSize = TextFieldAutoSize.LEFT;
        var titleFormat: TextFormat = label.defaultTextFormat;
        titleFormat.font = "Verdana";
        titleFormat.bold = true;
        titleFormat.color = 0xFFFFFF;
        titleFormat.size = 10;
		titleFormat.align = TextFormatAlign.LEFT;
        label.defaultTextFormat = titleFormat;
        label.multiline = false;
        label.selectable = false;
        label.wordWrap = false;
        label.text = caption;
        label.x = (this._width / 2) - (label.width / 2);
        label.y = (this._height / 2) - (label.height / 2);
        this.addChild(label);
        this.draw();
    }

    private function draw(): void
    {
        this.graphics.beginFill(this.bgColor);
        this.graphics.drawRoundRect(0, 0, this._width, this._height, 10, 10);
        this.graphics.endFill();
    }
}
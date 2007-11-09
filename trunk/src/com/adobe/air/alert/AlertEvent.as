package com.adobe.air.alert
{
	import flash.events.Event;

	public class AlertEvent extends Event
	{
		public static const ALERT_CLOSED_EVENT:String = "alertClosedEvent";

		public var detail: uint = 0;
		public function AlertEvent(detail: uint = 0) 
		{
			super(ALERT_CLOSED_EVENT);
			this.detail = detail;
		}
	}
}
# https://github.com/kivy/python-for-android/blob/master/doc/source/services.rst
# https://www.programcreek.com/python/example/99565/jnius.autoclass
# http://pyjnius.readthedocs.io/en/latest/android.html

import jnius

# install_twisted_rector must be called before importing and using the reactor
from kivy.support import install_twisted_reactor
install_twisted_reactor()
from twisted.internet import reactor
from twisted.internet import protocol

print("provost service BEGIN")

Context = jnius.autoclass('android.content.Context')
Intent = jnius.autoclass('android.content.Intent')
PendingIntent = jnius.autoclass('android.app.PendingIntent')
AndroidString = jnius.autoclass('java.lang.String')
NotificationBuilder = jnius.autoclass('android.app.Notification$Builder')
Notification = jnius.autoclass('android.app.Notification')

service = jnius.autoclass('org.sofwerx.provost.ProvostService')
PythonActivity = jnius.autoclass('org.kivy.android.PythonActivity').mActivity

notification_service = service.getSystemService(Context.NOTIFICATION_SERVICE)
app_context = service.getApplication().getApplicationContext()
notification_builder = NotificationBuilder(app_context)
title = AndroidString("Provost".encode('utf-8'))
message = AndroidString("Supporting The Observatory.".encode('utf-8'))
app_class = service.getApplication().getClass()
notification_intent = Intent(app_context, PythonActivity)
notification_intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP |
Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_NEW_TASK)
notification_intent.setAction(Intent.ACTION_MAIN)
notification_intent.addCategory(Intent.CATEGORY_LAUNCHER)
intent = PendingIntent.getActivity(service, 0, notification_intent, 0)
notification_builder.setContentTitle(title)
notification_builder.setContentText(message)
notification_builder.setContentIntent(intent)
Drawable = jnius.autoclass("{}.R$drawable".format(service.getPackageName()))
icon = getattr(Drawable, 'icon')
notification_builder.setSmallIcon(icon)
notification_builder.setAutoCancel(True)
new_notification = notification_builder.getNotification()

#Below sends the notification to the notification bar; nice but not a foreground service.
#notification_service.notify(0, new_noti)
service.startForeground(1, new_notification)

# https://kivy.org/docs/guide/other-frameworks.html

class EchoServer(protocol.Protocol):
    def dataReceived(self, data):
        response = self.factory.app.handle_message(data)
        if response:
            self.transport.write(response)


class EchoServerFactory(protocol.Factory):
    protocol = EchoServer

    def __init__(self, app):
        self.app = app


class TwistedServerApp(App):
    label = None

    def build(self):
        print("provost service build()")
        reactor.listenTCP(8000, EchoServerFactory(self))

    def handle_message(self, msg):
        print("provost service handle_message()")

        msg = msg.decode('utf-8')
        print(msg)

        if msg == "ping":
            msg = "Pong"
        if msg == "plop":
            msg = "Kivy Rocks!!!"
        return msg.encode('utf-8')

def run_server():
    print("provost service run_server()")
    serverapp = TwistedServerApp()
    serverapp.build()

if __name__ == '__main__':
    run_server()

#    TwistedServerApp().run()
print("provost service END")


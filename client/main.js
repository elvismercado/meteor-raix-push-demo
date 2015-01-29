Template.row.helpers({
	notificationHistory: function () {
		var query = {};
		if (Session.get("checked")) {
			query = {recievedAt: {$exists: !Session.get("checked")}};
		}
		return NotificationHistory.find(query);
	}
});

Template.list.events({
	"click #push": function () {
		Meteor.call("serverNotification");
	},
	"click #removeHistory": function () {
		Meteor.call("removeHistory");
	},
	"click input[type=checkbox]": function () {
		Session.set("checked", $("input[type=checkbox]").is(":checked"));
	}
});

Meteor.startup(function () {
	Meteor.defer(function () {
		Session.setDefault("checked", $("input[type=checkbox]").is(":checked"));
	});

	if (Meteor.isCordova) {
		window.alert = navigator.notification.alert;
	}

	Push.addListener('message', function(notification) {
		// Called on every message
		console.log(JSON.stringify(notification))

		function alertDismissed() {
			NotificationHistory.update({_id: notification.payload.historyId}, {
				$set: {
					"recievedAt": new Date()
				}
			});
		}
		alert(notification.message, alertDismissed, notification.payload.title, "Ok");
	});
})

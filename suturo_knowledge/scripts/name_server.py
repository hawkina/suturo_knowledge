#!/usr/bin/env python3

# Is person X already known to us?

import rospy
from std_srvs.srv import IsKnown
from suturo_knowledge.interf_q import InterfaceDoWeKnowYou

# When the Service "IsKnown" gets called and receives
# a string intent and a string name, the function "known_person" of the
# interface "InterfaceDoWeKnowYou" is called.
# Input is a String:
# "Bob"
# Output is a Bool and an info: 
# True if Bob is already known else False

def known_person(name):
    rospy.loginfo("second method is called :)")
    inter = InterfaceDoWeKnowYou()

    bool = inter.do_we_known_u(name)
    rospy.loginfo(bool)
    return bool


if __name__ == '__main__':
    rospy.init_node('name_service_server')
    rospy.Service('name_server', IsKnown, known_person)
    rospy.loginfo("name_server 2/4")
    rospy.spin()

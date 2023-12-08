#!/usr/bin/env python3

# What is the favourite drink of person X?

import rospy
from std_srvs.srv import GiveMeFavDrink
from suturo_knowledge.interf_q import InterfacePersonAndFavDrink


# When the Service "GiveMeFavDrink" gets called and receives
# a string intent and a string entities, the function "what_is_your_fav_drink" of the
# interface "InterfacePersonAndFavDrink" is called.
# Output: returns all favourite drinks of the person.
# Input is a String: 
# "Bob"
# Output is an object form the suturo.owl: 
# info Bobs favourite drink

def fav_drink_of_person_x(Name):

    rospy.loginfo("First interface is called :)")
    inter = InterfacePersonAndFavDrink()

    result = inter.what_is_your_fav_drink(Name)
    rospy.loginfo(result)
    return str(result)

  
if __name__ == '__main__':
    rospy.init_node('drink_service_server')
    rospy.Service('drink_server', GiveMeFavDrink, fav_drink_of_person_x)
    rospy.loginfo("drink_server 3/4")
    rospy.spin()

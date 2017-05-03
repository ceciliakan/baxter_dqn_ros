import roslib
import argparse
import sys 
import rospy
import rospkg
import cv2
from std_msgs.msg import String
from sensor_msgs.msg import Image
from sensor_msgs.msg import PointCloud2
from cv_bridge import CvBridge

class DepthMap_retriever(object):
	def __init__(self):
		self.bridge = CvBridge()
		self.dep_image_pub = rospy.Publisher("DepthMap", Image, queue_size=4)
		self.cloudpoint_pub = rospy.Publisher("Cloudy", String, queue_size=10)
		# self.dep_rgb_pub = rospy.Publisher("DepthCamColour", Image, queue_size=4)

	def dep_callback(self,data):
		self.cv_dep_image = self.bridge.imgmsg_to_cv2(data, "mono8")
		self.cv_dep_image = cv2.resize(self.cv_dep_image, (60, 60))
		cv2.imwrite("depth.jpg", self.cv_dep_image)
		self.depth_msg = self.bridge.cv2_to_imgmsg(self.cv_dep_image, "mono8")
		self.dep_image_pub.publish(self.depth_msg)
		
	def cloud_callback(self,data):
		self.cloudpoint_pub.publish("cloudy")

		
	def listener(self):
		self.cloudpoint_sub = rospy.Subscriber("/depth/points", PointCloud2, self.cloud_callback)
		self.dep_image_sub = rospy.Subscriber("/depth/image_raw", Image, self.dep_callback)
		# self.dep_rgb_sub = rospy.Subscriber("/DepCamera/image_raw",Image, self.dep_colour_callback)
		rospy.spin()

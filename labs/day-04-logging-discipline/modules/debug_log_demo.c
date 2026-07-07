#include <linux/delay.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>

static int loops = 3;
module_param(loops, int, 0644);
MODULE_PARM_DESC(loops, "Number of loop messages to emit");

static bool use_delay;
module_param(use_delay, bool, 0644);
MODULE_PARM_DESC(use_delay, "Sleep briefly between messages to make timestamps visible");

static int __init debug_log_demo_init(void)
{
	int i;

	pr_info("debug_log_demo: loaded, loops=%d use_delay=%d\n", loops, use_delay);
	pr_debug("debug_log_demo: enable with dynamic debug: echo 'module debug_log_demo +p' > /sys/kernel/debug/dynamic_debug/control\n");

	for (i = 0; i < loops; i++) {
		pr_info("debug_log_demo: pr_info sample %d/%d\n", i + 1, loops);
		pr_debug("debug_log_demo: pr_debug sample %d/%d\n", i + 1, loops);
		if (use_delay)
			msleep(100);
	}

	return 0;
}

static void __exit debug_log_demo_exit(void)
{
	pr_info("debug_log_demo: unloaded\n");
}

module_init(debug_log_demo_init);
module_exit(debug_log_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 4 logging and dynamic debug demo module");


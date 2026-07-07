#include <linux/init.h>
#include <linux/jiffies.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/timer.h>

static struct timer_list demo_timer;
static unsigned int delay_ms = 1000;
module_param(delay_ms, uint, 0644);
MODULE_PARM_DESC(delay_ms, "Initial timer delay");

static bool rearm;
module_param(rearm, bool, 0644);
MODULE_PARM_DESC(rearm, "Rearm the timer once from its callback");

static bool fired_once;

static void timer_demo_fn(struct timer_list *timer)
{
	pr_info("timer_demo: callback fired jiffies=%lu rearm=%d fired_once=%d\n",
		jiffies, rearm, fired_once);

	if (rearm && !fired_once) {
		fired_once = true;
		mod_timer(&demo_timer, jiffies + msecs_to_jiffies(delay_ms));
		pr_info("timer_demo: rearmed timer for %u ms\n", delay_ms);
	}
}

static int __init timer_demo_init(void)
{
	timer_setup(&demo_timer, timer_demo_fn, 0);
	mod_timer(&demo_timer, jiffies + msecs_to_jiffies(delay_ms));
	pr_info("timer_demo: started timer delay_ms=%u rearm=%d\n", delay_ms, rearm);
	return 0;
}

static void __exit timer_demo_exit(void)
{
	del_timer_sync(&demo_timer);
	pr_info("timer_demo: unloaded after del_timer_sync\n");
}

module_init(timer_demo_init);
module_exit(timer_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 24 timer lifecycle demo module");


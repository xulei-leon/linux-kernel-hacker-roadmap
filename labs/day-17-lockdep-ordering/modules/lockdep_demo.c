#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/mutex.h>

static DEFINE_MUTEX(lock_a);
static DEFINE_MUTEX(lock_b);

static bool trigger_inversion;
module_param(trigger_inversion, bool, 0644);
MODULE_PARM_DESC(trigger_inversion, "Trigger opposite lock ordering for lockdep practice");

static void take_a_then_b(void)
{
	mutex_lock(&lock_a);
	mutex_lock(&lock_b);
	mutex_unlock(&lock_b);
	mutex_unlock(&lock_a);
}

static void take_b_then_a(void)
{
	mutex_lock(&lock_b);
	mutex_lock(&lock_a);
	mutex_unlock(&lock_a);
	mutex_unlock(&lock_b);
}

static int __init lockdep_demo_init(void)
{
	pr_info("lockdep_demo: loaded trigger_inversion=%d\n", trigger_inversion);
	take_a_then_b();

	if (trigger_inversion) {
		pr_alert("lockdep_demo: taking B then A after A then B; expect lockdep warning when enabled\n");
		take_b_then_a();
	}

	return 0;
}

static void __exit lockdep_demo_exit(void)
{
	pr_info("lockdep_demo: unloaded\n");
}

module_init(lockdep_demo_init);
module_exit(lockdep_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 17 lockdep ordering demo module");

